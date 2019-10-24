(define (problem problem2)
    (:domain spaceport)

    (:objects
        region1 region2 region3 region4 - region

        captain - captain
        engineer1 engineer2 engineer3 - engineer ; There must be at least three
        officer1 officer2 - scienceOfficer
        navigator1 - navigator
        rescuer1 - rescuer

        bridge - bridge
        launchBay - launchBay
        scienceLab - scienceLab
        engineering - engineering
        s1 - bedrooms

        probe1 probe2 - probe
        lander1 lander2 - lander
        mav1 mav2 - mav
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
        
        (high_radiation jupiter)
        (has_place_to_land earth)
        (info_of_touchdown_location earth)
        (has_place_to_land mars)
        (has_place_to_land jupiter)
        
        (contains region1 earth)
        (contains region2 mars)
        (contains region3 nebula1)
        (has_asteroid_belt region3)
        (contains region4 nebula2)

        (adjacent region1 region2)
        (adjacent region2 region3)
        (adjacent region3 region4)

        (connected s1 launchBay)
        (connected s1 bridge)
        (connected s1 engineering)
        (connected s1 scienceLab)
        
        (is_on captain s1)
        (is_on engineer1 s1)
        (is_on engineer2 s1)
        (is_on engineer3 s1)
        (is_on officer1 s1)
        (is_on officer2 s1)
        (is_on navigator1 s1)
        (is_on rescuer1 s1)
    )

    (:goal
        (and
            (studies_of_plasma_from_nebula nebula2)
            (not (scanned_planet jupiter))
            (not (scanned_planet earth))
            (not (scanned_planet mars))
            (on_planet earth)
            (not (travelling))
        )
    )
)
