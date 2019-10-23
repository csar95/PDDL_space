# F29AI_CW1_PDDL

- When trying to collect nebula from a region with asteroids, all probes will be destroyed.
- It is recommended to establish "not travelling" as a goal. Otherwise, a navigator could have the order to go somewhere else but lands on Earth because all the goal are achieved.

(or 
    (results_of_planetary_scan jupiter)
    (forall (?l - lander)
        (crashed ?l)
    )
)