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
        (connected ?s1 - section ?s2 - section)
        (adjacent ?r1 - region ?r2 - region)

        (contains ?r - region ?x - entity)                          ; When a region doesn't contain anything, it's empty.
        (has_asteroid_belt ?r - region)
        (has_place_to_land ?p - planet)
        (has_spaceport ?p - planet)
        (high_radiation ?p - planet)

        (is_on ?p - personnel ?s - section)
        (received_order_to_travel ?p - navigator ?r - region)
        (transferring_plasma_from ?p - scienceOfficer ?n - nebula)
        (repairing_inside_MAV ?p - engineer ?m - mav)
        (calling_for_help ?p - engineer)                            ; [ADDITIONAL FEATURE]: An engineer asks for a rescue from a disable MAV.
        (rescuing ?p - rescuer)

        (on_board ?d - device)                                      ; Devices are on board and ready to be launched.
        (disabled ?d - device)                                      ; A device is either destroyed in an asteroid belt (probe), crashed on a planet (lander) or disabled while repairing (MAV).
        (deployed_to_study_at ?p - probe ?z - entity ?r - region)   ; A probe is deployed to study either a planet or a nebula.
        (landed_on_planet ?l - lander ?p - planet)
        (deployed_one_antenna ?l - lander)
        (deployed_two_antennae ?l - lander)

        (on_region ?r - region)
        (on_planet ?p - planet)
        (travelling)
        (is_damaged)
        (scanning_surface_of_planet ?p - planet)                    ; A probe is scanning the surface of a planet.
        (exploring_planet ?p - planet)                              ; A lander is scanning a planet.
        (scanned_planet ?p - planet)                                ; The surface of a planet has been already scanned.
        (info_of_touchdown_location ?p - planet)                    ; The spacecraft's central computer knows the touchdown location of a planet.
        (results_of_planetary_scan ?p - planet)                     ; The spacecraft’s central computer contains planetary scans of a planet.
        (studies_of_plasma_from_nebula ?n - nebula)                 ; The spacecraft's central computer contains studies of plasma from a particular nebula.
        (plasma_from_nebula_at_section ?n - nebula ?s - section)
        (end_missions)                                              ; Flag to mark when the spacecraft has ended the mission and communicated the results to Earth.
    )

    ; The spacecraft can take off from a planet.
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
                (on_region ?from)       ; The spacecraft is out in space.
            )
    )

    ; The spacecraft can land on a planet.
    (:action land_spacecraft
        :parameters
            (?p - planet ?from - region)
        :precondition
            (and
                (info_of_touchdown_location ?p)     ; The central computer knows the touchdown location of the planet on which the ship is about to land.
                (on_region ?from)
                (contains ?from ?p)
                (forall (?prb - probe)              ; The spacecraft cannot leave if a probe is deployed on a planet.
                    (or (disabled ?prb) (on_board ?prb))
                )
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
                (is_on ?c ?brdg)        ; Captain is on the bridge.
                (is_on ?n ?brdg)        ; Navigator is present to receive the order.
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
            (?nav - navigator ?controlledFrom - bridge ?from - region ?to - region ?destination - region)
        :precondition
            (and
                (on_region ?from)
                (or (adjacent ?from ?to) (adjacent ?to ?from))
                (not (is_damaged))                              ; The ship isn’t damaged.                
                (is_on ?nav ?controlledFrom)                    ; Navigator is on the bridge.
                (travelling)
                (received_order_to_travel ?nav ?destination)    ; The navigator must have received an order to travel to that region.
                (forall (?prb - probe)                          ; The spacecraft cannot leave if a probe is deployed on a planet.
                    (or (disabled ?prb) (on_board ?prb))
                )
            )
        :effect
            (and
                (not (on_region ?from))
                (on_region ?to)                
                (when (has_asteroid_belt ?to)                   ; The spacecraft enters a region with an asteroid belt and becomes damaged.
                    (is_damaged)
                )
                (when (= ?to ?destination)
                    (and                        
                        (not (received_order_to_travel ?nav ?destination))  ; Ship reaches destination, so navigator becomes idle.
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
                (is_damaged)                            ; The ship is damaged.
                (on_region ?at)                
                (is_on ?monitoredBy ?eng)               ; An engineer must monitor the operation from engineering.
                (is_on ?controlledBy ?bay)              ; An engineer is in the launch bay to operate the launch controls.
                (is_on ?pilot ?bay)                     ; The repairman is in the launch bay where MAVs are launched.
                (not (= ?pilot ?controlledBy))
                (not (repairing_inside_MAV ?pilot ?m))  ; MAV is on launch bay
                (not (disabled ?m))                     ; and it's not disabled.                
            )
        :effect            
            (and
                (repairing_inside_MAV ?pilot ?m)        ; Engineer is repairing inside the MAV                
                (not (is_on ?pilot ?bay))               ; and leaves the launch bay.
                (forall (?nbl - nebula)
                    (when (contains ?at ?nbl)           ; If a MAV is deployed in a region with a nebula, the MAV is disabled.
                        (and
                            (disabled ?m)
                            (calling_for_help ?pilot)   ; [ADDITIONAL FEATURE]: The pilots calls the rescuer for help.
                        )
                    )
                )
            )
    )

    ; [ADDITIONAL FEATURE]: A rescuer can go to fix a disabled MAV inside a capsule so that the
    ; engineer can continue his work and the ship resume the travel.
    (:action rescue_disabled_MAV
        :parameters
            (?rscr - rescuer ?cpsl - capsule ?bay - launchBay ?pilot - engineer ?m - mav)
        :precondition
            (and
                
                (calling_for_help ?pilot)   ; There is an engineer calling for help
                (disabled ?m)               ; because his MAV is disabled.
                (on_board ?cpsl)            ; A rescuer leaves from the launch bay to rescue MAV, giving there is a capsule on board.
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

    ; [ADDITIONAL FEATURE]: Once the rescuer completes his task, the MAV is not disabled
    ; and he returns to the spacecraft.
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

    ; MAV is retrieved back into the launch bay.
    (:action call_back_mav
        :parameters
            (?m - mav ?controlledBy - engineer ?bay - launchBay ?pilot - engineer)
        :precondition
            (and
                (not (is_on ?pilot ?bay))
                (repairing_inside_MAV ?pilot ?m)    ; There's an engineer repairing the ship.
                (not (disabled ?m))                
                (is_on ?controlledBy ?bay)          ; Another engineer is present in launch bay.
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
                (not (travelling))              ; The ship cannot be travelling.
                (not (is_damaged))              ; and it must be operational.
                (on_region ?at)                 ; The ship is on a region with nebula.
                (contains ?at ?nbl)
                (on_board ?prb)                 ; There is a probe on board ready to be sent.
                (not (disabled ?prb))                
                (is_on ?controlledBy ?bay)      ; An engineer is in the launch bay to operate the launch controls.
            )
        :effect
            (and
                (not (on_board ?prb))
                (when (not (has_asteroid_belt ?at))
                    (deployed_to_study_at ?prb ?nbl ?at)
                )
                (when (has_asteroid_belt ?at)   ; If a probe is deployed in a region with an asteroid belt, the probe is destroyed.
                    (disabled ?prb)
                )
            )
    )

    ; Probe is retrieved back into the launch bay with a sample of plasma.
    (:action call_back_probe_with_plasma
        :parameters
            (?prb - probe ?controlledBy - engineer ?bay - launchBay ?at - region ?nbl - nebula)
        :precondition
            (and
                (on_region ?at)
                (not (on_board ?prb))
                (not (disabled ?prb))
                (deployed_to_study_at ?prb ?nbl ?at)                
                (is_on ?controlledBy ?bay)                  ; An engineer is present in launch bay.
            )
        :effect
            (and
                (on_board ?prb)
                (not (deployed_to_study_at ?prb ?nbl ?at))                
                (plasma_from_nebula_at_section ?nbl ?bay)   ; Collected plasma is automatically transferred into the launch bay.
            )
    )

    ; A probe can be deployed to scan a planet to find a touchdown location.
    (:action sent_to_scan_planet
        :parameters
            (?prb - probe ?at - region ?plnt - planet ?controlledBy - engineer ?bay - launchBay)
        :precondition
            (and
                (not (end_missions))                        ; Avoids communicating results before performing any study
                (not (travelling))                          ; The ship cannot be travelling.
                (not (is_damaged))                          ; and it must be operational.                                
                (not (scanning_surface_of_planet ?plnt))    ; Avoids two probes scanning a planet simultaneously.
                (not (scanned_planet ?plnt))                ; The planet hasn't been visited yet.                
                (on_region ?at)                             ; The ship is on a region with a planet.
                (contains ?at ?plnt)
                (on_board ?prb)                             ; There is a probe on board ready to be sent.
                (not (disabled ?prb))
                (is_on ?controlledBy ?bay)                  ; An engineer is in the launch bay to operate the launch controls.
            )
        :effect
            (and                
                (not (on_board ?prb))
                (when (not (has_asteroid_belt ?at))
                    (and
                        (scanning_surface_of_planet ?plnt)
                        (deployed_to_study_at ?prb ?plnt ?at)
                    )
                )
                (when (has_asteroid_belt ?at)               ; If a probe is deployed in a region with an asteroid belt, the probe is destroyed.
                    (disabled ?prb)
                )
            )
    )

    ; Probo is retrieved back into the launch bay after scanning a planet.
    (:action call_back_probe_from_planet
        :parameters
            (?prb - probe ?controlledBy - engineer ?bay - launchBay ?plnt - planet ?at - region)
        :precondition
            (and
                (on_region ?at)
                (contains ?at ?plnt)
                (scanning_surface_of_planet ?plnt)
                (not (on_board ?prb))
                (not (disabled ?prb))
                (deployed_to_study_at ?prb ?plnt ?at)                
                (is_on ?controlledBy ?bay)              ; An engineer is present in launch bay.
            )
        :effect
            (and
                (not (scanning_surface_of_planet ?plnt))
                (not (deployed_to_study_at ?prb ?plnt ?at))
                (on_board ?prb)
                (scanned_planet ?plnt)                  ; Scans are copied into the spacecraft's central computer.
                (when (has_place_to_land ?plnt)         ; If planet has a place to land, the central computer will know the touchdown location of that planet
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
                (plasma_from_nebula_at_section ?nbl ?bay)       ; There is plasma at the launch bay.                
                (is_on ?officer ?bay)                           ; Officer is at the launch bay to transport the plasma.                
                (not (transferring_plasma_from ?officer ?nbl))  ; Officer is idle.
            )
        :effect
            (and
                (transferring_plasma_from ?officer ?nbl)
                (not (plasma_from_nebula_at_section ?nbl ?bay))
            )
    )

    ; A science officer takes the plasma to the science lab and studies it.
    ; Only science officers can study plasma.
    (:action officer_studies_plasma_from
        :parameters
            (?officer - scienceOfficer ?nbl - nebula ?lab - scienceLab)
        :precondition
            (and
                (not (end_missions))                            ; Avoids communicating results before performing any study
                (transferring_plasma_from ?officer ?nbl)        ; The officer brings the plasma.                 
                (is_on ?officer ?lab)                           ; Plasma studies must take place in the science lab.
            )
        :effect
            (and                
                (plasma_from_nebula_at_section ?nbl ?lab)       ; Leave samples of plasma at the science lab (no need to discard them).
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
                (on_board ?l)                           ; Lander has not landed on any other planet.                
                (not (exploring_planet ?p))             ; There is no other lander on this planet.
            )
        :effect
            (and
                (not (on_board ?l))
                (when (info_of_touchdown_location ?p)   ; If central computer has touchdown location, the lander can land.
                    (and
                        (landed_on_planet ?l ?p)
                        (exploring_planet ?p)           ; A lander scans the planet if it has successfully landed.
                        (deployed_one_antenna ?l)       ; The lander deploys one antenna to communicate results.
                    )
                )
                (when (and (info_of_touchdown_location ?p) (high_radiation ?p))
                    (deployed_two_antennae ?l)          ; The lander deploys a second antenna if planet has high radiation.
                )
                (when (not (info_of_touchdown_location ?p))
                    (disabled ?l)                       ; A lander attempting to land without a touchdown location will crash.
                )
            )
    )

    ; Receive results in spacecraft's computers.
    (:action receive_scanning_results
        :parameters
            (?p - planet ?l - lander)
        :precondition
            (and
                (not (end_missions))    ; Avoids communicating results before performing any study
                (not (on_board ?l))
                (not (disabled ?l))
                (landed_on_planet ?l ?p)
                (exploring_planet ?p)
                (or (deployed_one_antenna ?l) (deployed_two_antennae ?l))
            )
        :effect
            (results_of_planetary_scan ?p)
    )
    
    ; When the spacecraft returns to Earth, results of studies and scans are communicated to
    ; Mission Control at the SpacePort to successfully end the mission.
    (:action communicate_results_to_mission_control
        :parameters
            (?plnt - planet)
        :precondition
            (and
                (not (travelling))
                (on_planet ?plnt)
                (has_spaceport ?plnt)   ; In the definition of the problems we establish that the Earth is the only planet with a spaceport
            )
        :effect
            (end_missions)
    )
    
)
