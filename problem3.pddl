; #################################### PROBLEM DESCRIPTION ####################################
; This problem proves that landers and probes can crash or be destroyed if a planet doesn't have
; a place to land or the region has an asteroid belt.
; #############################################################################################


(define (problem problem3)
    (:domain spaceport)

    (:objects
        region1 region2 region3 - region

        captain - captain
        engineer1 engineer2 engineer3 - engineer
        officer1 - scienceOfficer
        navigator1 - navigator
        rescuer1 - rescuer

        bridge - bridge
        launchBay - launchBay
        scienceLab - scienceLab
        engineering - engineering
        s1 - bedrooms

        probe1 probe2 - probe
        lander1 lander2 - lander
        mav1 - mav
        capsule1 - capsule

        earth mars jupiter - planet
        nebula1 - nebula
    )

    (:init
        (on_board probe1)
        (on_board probe2)
        (on_board lander1)
        (on_board lander2)
        (on_board capsule1)

        (on_planet earth)
        (has_spaceport earth)
        (info_of_touchdown_location earth)
        
        ; All planets excepct Jupiter have a place to land
        (has_place_to_land earth)
        (has_place_to_land mars)
        
        (contains region1 earth)
        (contains region2 mars)
        (has_asteroid_belt region2)
        (contains region3 jupiter)

        (adjacent region1 region2)
        (adjacent region2 region3)

        (connected s1 launchBay)
        (connected s1 bridge)
        (connected s1 engineering)
        (connected s1 scienceLab)
        
        (is_on captain s1)
        (is_on engineer1 s1)
        (is_on engineer2 s1)
        (is_on engineer3 s1)
        (is_on officer1 s1)
        (is_on navigator1 s1)
        (is_on rescuer1 s1)
    )

    (:goal
        (and
            (not (scanned_planet earth))
            ; All landers should crash on Jupiter because it doesn't have a place to land.
            (forall (?lnd - lander)
                (disabled ?lnd)
            )
            ; All probes should get destroyed on region 2 attempting to scan Mars because of the
            ; asteroid belt existing in the same region.
            (forall (?prb - probe)
                (disabled ?prb)
            )
            (end_missions)
        )
    )
)
