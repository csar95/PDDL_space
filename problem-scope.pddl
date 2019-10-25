(define (problem problem1)
    (:domain spaceport)

    (:objects
        region1 region2 region3 region4 region5 region6 region7 region8 - region

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
        lander1 lander2 lander3 lander4 lander5 lander6 lander7 lander8 - lander
        mav1 - mav
        capsule1 - capsule

        mercury venus earth mars jupiter saturn uranus neptune - planet
        ;earth mars - planet
        nebula1 - nebula
    )

    (:init
        (on_board probe1)
        (on_board lander1)
        (on_board lander2)
        (on_board lander3)
        (on_board lander4)
        (on_board lander5)
        (on_board lander6)
        (on_board lander7)
        (on_board lander8)
        (on_board capsule1)

        (on_planet earth)
        
        (has_place_to_land earth)
        (info_of_touchdown_location earth)
        (has_place_to_land mars)
        (has_place_to_land jupiter)
        (has_place_to_land saturn)
        (has_place_to_land uranus)
        (has_place_to_land neptune)
        (has_place_to_land mercury)
        (has_place_to_land venus)
        
        (contains region1 earth)
        (contains region2 mars)
        (contains region3 jupiter)
        (contains region4 saturn)
        (contains region5 uranus)
        (contains region6 neptune)
        (contains region7 mercury)
        (contains region8 venus)

        (adjacent region1 region2)
        (adjacent region2 region3)
        (adjacent region3 region4)
        (adjacent region4 region5)
        (adjacent region5 region6)
        (adjacent region6 region7)
        (adjacent region7 region8)

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
            (results_of_planetary_scan mars)
            (results_of_planetary_scan jupiter)
            (results_of_planetary_scan saturn)
            (results_of_planetary_scan uranus)
            (results_of_planetary_scan neptune)
            (results_of_planetary_scan mercury)
            (results_of_planetary_scan venus)
            (on_planet earth)
            (not (travelling))
        )
    )
)