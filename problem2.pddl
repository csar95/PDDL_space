; #################################### PROBLEM DESCRIPTION ####################################
; This problem tests a scenario where the spacecraft's mission consists of several operations.
; On the way it needs to pass through a region which contains an asteroid belt, adding a bit of
; complexity to the mission.
; #############################################################################################


(define (problem problem2)
    (:domain spaceport)

    (:objects
        region1 region2 region3 region4 region5 - region

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
        nebula1 nebula2 - nebula
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
        
        ; All planets have a place to land
        (has_place_to_land earth)
        (has_place_to_land mars)
        (has_place_to_land jupiter)
        
        (contains region1 earth)
        (contains region2 mars)
        (has_asteroid_belt region3)
        (contains region4 jupiter)
        (contains region4 nebula1)
        (contains region5 nebula2)

        (adjacent region1 region2)
        (adjacent region2 region3)
        (adjacent region3 region4)
        (adjacent region4 region5)

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
            (results_of_planetary_scan mars)
            (results_of_planetary_scan jupiter)
            (studies_of_plasma_from_nebula nebula1)
            (studies_of_plasma_from_nebula nebula2)
            (end_missions)
        )
    )
)
