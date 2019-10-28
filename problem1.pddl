; #################################### PROBLEM DESCRIPTION ####################################
; This problem tests a simple scenario where the spacecraft has the mission to get results of a
; planetary scan from a particular planet and study the plasma from a nebula located a few 
; regions away.
; #############################################################################################


(define (problem problem1)
    (:domain spaceport)

    (:objects
        region1 region2 region3 - region

        captain - captain
        engineer1 engineer2 engineer3 - engineer  ; There must be at least three
        officer1 - scienceOfficer
        navigator1 - navigator
        rescuer1 - rescuer

        bridge - bridge
        launchBay - launchBay
        scienceLab - scienceLab
        engineering - engineering
        s1 - bedrooms

        probe1 - probe
        lander1 - lander
        mav1 - mav
        capsule1 - capsule

        earth mars - planet
        nebula1 - nebula
    )

    (:init
        (on_board probe1)
        (on_board lander1)
        (on_board capsule1)

        (on_planet earth)
        (has_spaceport earth)
        (info_of_touchdown_location earth)
        
        (has_place_to_land earth)
        (has_place_to_land mars)
        
        (contains region1 earth)
        (contains region2 mars)
        (contains region3 nebula1)

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
            (not (scanned_planet earth))  ; This ensures that the planner doesn't take extra actions.
            (results_of_planetary_scan mars)
            (studies_of_plasma_from_nebula nebula1)
            (end_missions)
        )
    )
)
