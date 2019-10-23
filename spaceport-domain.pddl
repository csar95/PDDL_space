(define (domain spaceport)
    (:requirements
        :strips :conditional-effects :typing :equality
    )

    (:types
        probe lander mav capsule - device
        region
        captain engineer scienceOfficer navigator rescuer - personnel
        bridge launchBay scienceLab engineering bedrooms - section
        planet nebula - entity
    )

    (:predicates
        (high_radiation ?p - planet)
        (has_place_to_land ?p - planet)
        ; When a region doesn't contain anything, it's empty.
        (has_asteroid_belt ?r - region)
        (has_nebula ?r - region)
        (contains ?r - region ?x - entity)
        (adjacent ?r1 - region ?r2 - region)

        (connected ?s1 - section ?s2 - section)

        (is_on ?p - personnel ?s - section)
        (received_order_to_travel ?p - navigator ?r - region)
        (transferring_plasma_from ?p - scienceOfficer ?n - nebula)
        (rescuing ?p - rescuer)
        (calling_for_help ?p - engineer)
        
        (scanning_surface_of_planet ?p - planet)
        (scanned_planet ?p - planet)
        (exploring_planet ?p - planet)

        (is_damaged)
        (travelling)
        (on_region ?r - region)
        (on_planet ?p - planet)

        ; Ready to be launched from the launch bay
        (on_board ?d - device)
        (destroyed ?p - probe)
        (deployed_to_study_at ?p - probe ?z - entity ?r - region)
        (repairing_inside_MAV ?p - engineer ?m - mav)
        (disabled ?r - mav)
        (landed_on_planet ?l - lander ?p - planet)
        (crashed ?l - lander)
        (deployed_one_antenna ?l - lander)
        (deployed_two_antennae ?l - lander)

        (plasma_from_nebula_at_section ?n - nebula ?s - section)
        (studies_of_plasma_from_nebula ?n - nebula)
        ; There exist scans of a planet in spacecraft’s central computer.
        (info_of_touchdown_location ?p - planet)
        (results_of_planetary_scan ?p - planet)
    )

    (:action launch_spacecraft
        :parameters
            (?p - planet ?from - region)
        :precondition
            (and
                (on_planet ?p)
                (contains ?from ?p)
            )
        :effect
            (and
                (not (on_planet ?p))
                (on_region ?from)
            )
    )

    (:action land_spacecraft
        :parameters
            (?p - planet ?from - region)
        :precondition
            (and
                (info_of_touchdown_location ?p)
                (on_region ?from)
                (contains ?from ?p)
            )
        :effect
            (and
                (not (on_region ?from))
                (on_planet ?p)
            )
    )

    ; A person can move between sections that are connected.
    (:action move
        :parameters
            (?p - personnel ?from - section ?to - section)
        :precondition
            (and
                (is_on ?p ?from)
                (or (connected ?from ?to) (connected ?to ?from))
            )
        :effect
            (and
                (not (is_on ?p ?from))
                (is_on ?p ?to)
            )
    )

    ; The captain orders a travel to a region.
    (:action order_to_travel_to_region
        :parameters
            (?c - captain ?n - navigator ?brdg - bridge ?to - region)
        :precondition
            (and
                (not (travelling))
                (not (on_region ?to))
                ; Captain is on the bridge.
                (is_on ?c ?brdg)
                ; Navigator is present to receive the order.
                (is_on ?n ?brdg)
                ; Navigator not working
                (forall (?r - region)
                    (not (received_order_to_travel ?n ?r))
                )
            )
        :effect
            (and
                (received_order_to_travel ?n ?to)
                (travelling)
            )
    )

    ; The spacecraft travels to a region of space.
    (:action travelling_to_region
        :parameters
            (?controlledBy - navigator ?controlledFrom - bridge ?from - region ?to - region ?destination - region)
        :precondition
            (and
                (on_region ?from)
                (or (adjacent ?from ?to) (adjacent ?to ?from))
                ; The ship isn’t damaged.
                (travelling)
                (not (is_damaged))
                ; Navigator is on the bridge.
                (is_on ?controlledBy ?controlledFrom)
                ; The navigator must have received an order to travel to that region.
                (received_order_to_travel ?controlledBy ?destination)
                ; The spacecraft cannot leave if a probe is deployed on a planet.
                (forall (?p - probe)
                    (or (destroyed ?p) (on_board ?p))
                )
            )
        :effect
            (and
                (not (on_region ?from))
                (on_region ?to)
                ; The spacecraft enters a region with an asteroid belt and becomes damaged.
                (when (has_asteroid_belt ?to)
                    (is_damaged)
                )
                (when (= ?to ?destination)
                    (and
                        ; Ship has reached destination, so navigator becomes idle.
                        (not (received_order_to_travel ?controlledBy ?destination))
                        (not (travelling))
                    )
                )
            )
    )

    ; An engineer can repair the ship by performing an EVA while inside a MAV.
    (:action sent_to_repair_ship
        :parameters
            (?pilot - engineer ?m - mav ?monitoredBy - engineer ?eng - engineering ?controlledBy - engineer ?bay - launchBay ?at - region)
        :precondition
            (and
                ; The ship is damaged.
                (is_damaged)
                (on_region ?at)
                ; An engineer must monitor the operation from engineering.
                (is_on ?monitoredBy ?eng)
                ; An engineer is in the launch bay to operate the launch controls.
                (is_on ?controlledBy ?bay)
                ; The repairman is in the launch bay where MAVs are launched.
                (is_on ?pilot ?bay)
                (not (= ?pilot ?controlledBy))
                ; MAV is on launch bay.
                (not (disabled ?m))
                (not (repairing_inside_MAV ?pilot ?m))
            )
        :effect
            ; If a MAV is deployed in a region with a nebula, the MAV is disabled.
            (and
                (repairing_inside_MAV ?pilot ?m)
                ; Engineer inside MAV leaves the launch bay.
                (not (is_on ?pilot ?bay))
                (when (has_nebula ?at)
                    (and
                        (disabled ?m)
                        (calling_for_help ?pilot)
                    )
                )                
            )
    )

    ; [ADDITIONAL FEATURE]: A rescuer can go to fix a disabled MAV inside a capsule so that the
    ; ship can be repaired and continue its journey.
    (:action rescue_disabled_MAV
        :parameters
            (?rscr - rescuer ?cpsl - capsule ?bay - launchBay ?pilot - engineer ?m - mav)
        :precondition
            (and
                ; There is an engineer calling for help because his MAV has been disabled
                (calling_for_help ?pilot)
                (disabled ?m)
                ; A rescuer leaves from the launch bay to rescue MAV, giving there is a capsule on board.
                (on_board ?cpsl)
                (is_on ?rscr ?bay)
                (not (rescuing ?rscr))
            )
        :effect
            (and
                (not (on_board ?cpsl))
                (not (is_on ?rscr ?bay))
                (rescuing ?rscr)
                (not (calling_for_help ?pilot))
            )
    )

    ; [ADDITIONAL FEATURE]: Once the rescuer completes his task, the MAV is not disabled and he returns to the spacecraft.
    (:action enable_MAV_and_return
        :parameters
            (?m - mav ?rscr - rescuer ?cpsl - capsule ?bay - launchBay)
        :precondition
            (and
                (disabled ?m)
                (rescuing ?rscr)
                (not (is_on ?rscr ?bay))
            )
        :effect
            (and
                (not (disabled ?m))
                (not (rescuing ?rscr))
                (is_on ?rscr ?bay)
                (on_board ?cpsl)
            )
    )

    (:action call_back_mav
        :parameters
            (?m - mav ?controlledBy - engineer ?bay - launchBay ?pilot - engineer)
        :precondition
            (and
                (repairing_inside_MAV ?pilot ?m)
                (not (is_on ?pilot ?bay))
                (not (disabled ?m))
                ; An engineer is present in launch bay.
                (is_on ?controlledBy ?bay)
            )
        :effect
            (and
                (not (is_damaged))
                (not (repairing_inside_MAV ?pilot ?m))
                (is_on ?pilot ?bay)
            )
    )

    ; A probe can be deployed to collect a sample of plasma.
    (:action sent_to_collect_plasma
        :parameters
            (?prb - probe ?at - region ?nbl - nebula ?controlledBy - engineer ?bay - launchBay)
        :precondition
            (and
                (not (travelling))
                ; The ship is on a region with nebula.
                (not (is_damaged))
                (on_region ?at)
                (contains ?at ?nbl)
                ; There is a probe on board ready to be sent.
                (on_board ?prb)
                (not (destroyed ?prb))                
                ; An engineer is in the launch bay to operate the launch controls.
                (is_on ?controlledBy ?bay)
            )
        :effect
            (and
                (not (on_board ?prb))
                (when (not (has_asteroid_belt ?at))
                    (deployed_to_study_at ?prb ?nbl ?at)
                )
                (when (has_asteroid_belt ?at)
                    (destroyed ?prb)
                )
            )
    )

    (:action call_back_probe_with_plasma
        :parameters
            (?prb - probe ?controlledBy - engineer ?bay - launchBay ?at - region ?nbl - nebula)
        :precondition
            (and
                (on_region ?at)

                (not (on_board ?prb))
                (not (destroyed ?prb))
                (deployed_to_study_at ?prb ?nbl ?at)
                ; An engineer is present in launch bay.
                (is_on ?controlledBy ?bay)
            )
        :effect
            (and
                (on_board ?prb)
                (not (deployed_to_study_at ?prb ?nbl ?at))
                ; Collected plasma is automatically transferred into the launch bay.
                (plasma_from_nebula_at_section ?nbl ?bay)
            )
    )

    ; A probe can be deployed to scan a planet to find a touchdown location
    (:action sent_to_scan_planet
        :parameters
            (?prb - probe ?at - region ?plnt - planet ?controlledBy - engineer ?bay - launchBay)
        :precondition
            (and
                (not (travelling))
                (on_board ?prb)
                ; The planet hasn't been visited yet.
                (not (scanning_surface_of_planet ?plnt))
                (not (scanned_planet ?plnt))
                ; The ship is on a region with a planet.
                (not (is_damaged))
                (on_region ?at)
                (contains ?at ?plnt)
                ; There is a probe on board ready to be sent.
                (not (destroyed ?prb))
                ; An engineer is in the launch bay to operate the launch controls.
                (is_on ?controlledBy ?bay)
            )
        :effect
            (and
                (scanning_surface_of_planet ?plnt)
                (not (on_board ?prb))
                (when (not (has_asteroid_belt ?at))
                    (deployed_to_study_at ?prb ?plnt ?at)
                )
                (when (has_asteroid_belt ?at)
                    (destroyed ?prb)
                )
            )
    )

    (:action call_back_probe_from_planet
        :parameters
            (?prb - probe ?controlledBy - engineer ?bay - launchBay ?plnt - planet ?at - region)
        :precondition
            (and
                (on_region ?at)
                (contains ?at ?plnt)
                (scanning_surface_of_planet ?plnt)
                (not (on_board ?prb))
                (not (destroyed ?prb))
                (deployed_to_study_at ?prb ?plnt ?at)
                ; An engineer is present in launch bay.
                (is_on ?controlledBy ?bay)
            )
        :effect
            (and
                (not (scanning_surface_of_planet ?plnt))
                (not (deployed_to_study_at ?prb ?plnt ?at))
                (on_board ?prb)
                (scanned_planet ?plnt)
                (when (has_place_to_land ?plnt)
                    (info_of_touchdown_location ?plnt)
                )    
            )
    )

    ; A science officer takes plasma from launch bay in order to bring it to the science lab.
    (:action officer_collects_plasma_from
        :parameters
            (?officer - scienceOfficer ?nbl - nebula ?bay - launchBay)
        :precondition
            (and
                ; There is plasma at the launch bay.
                (plasma_from_nebula_at_section ?nbl ?bay)
                ; Officer is at the launch bay to transport the plasma.
                (is_on ?officer ?bay)
                ; Officer is idle.
                (not (transferring_plasma_from ?officer ?nbl))
            )
        :effect
            (and
                (transferring_plasma_from ?officer ?nbl)
                (not (plasma_from_nebula_at_section ?nbl ?bay))
            )
    )

    ; A science officer takes the plasma to the science lab and studies it.
    (:action officer_studies_plasma_from
        :parameters
            (?officer - scienceOfficer ?nbl - nebula ?lab - scienceLab)
        :precondition
            (and
                ; The officer brings the plasma.
                (transferring_plasma_from ?officer ?nbl)
                ; Plasma studies must take place in the science lab. Only science officers can study plasma.
                (is_on ?officer ?lab)
            )
        :effect
            (and
                ; Leave samples of plasma at the science lab (no need to throw them away).
                (plasma_from_nebula_at_section ?nbl ?lab)
                (not (transferring_plasma_from ?officer ?nbl))
                (studies_of_plasma_from_nebula ?nbl)
            )
    )

    ; A lander lands on a planet provided it has a touchdown location. Without the location it will crash.
    (:action attempt_to_land_on_planet
        :parameters
            (?l - lander ?p - planet ?at - region)
        :precondition
            (and
                (not (travelling))
                (scanned_planet ?p)
                (not (scanning_surface_of_planet ?p))
                (not (is_damaged))
                (on_region ?at)
                (contains ?at ?p)
                ; Lander has not landed on any other planet.
                (on_board ?l)
                ; There is no other lander on this planet.
                (not (exploring_planet ?p))
            )
        :effect
            (and
                (not (on_board ?l))
                (when (info_of_touchdown_location ?p)
                    (and
                        (landed_on_planet ?l ?p)
                        (exploring_planet ?p)
                        (deployed_one_antenna ?l)
                    )
                )
                (when (and (info_of_touchdown_location ?p) (high_radiation ?p))
                    (deployed_two_antennae ?l)
                )
                (when (not (info_of_touchdown_location ?p))
                    (crashed ?l)
                )
            )
    )

    ; Receive results in spacecraft's computers.
    (:action receive_scanning_results
        :parameters
            (?p - planet ?l - lander)
        :precondition
            (and
                (not (on_board ?l))
                (not (crashed ?l))
                (landed_on_planet ?l ?p)
                (exploring_planet ?p)
                (or (deployed_one_antenna ?l) (deployed_two_antennae ?l))
            )
        :effect
            (results_of_planetary_scan ?p)
    )
    
)
