# Planning: The Responsibility Cascade System

## 1. Core Concept

The "Responsibility Cascade" is a core, pervasive system in the game that represents the invisible emotional labor and cognitive load the protagonist (Rando) experiences. It is the constant, often subconscious, process of calculating the chain of dependencies, emotional reactions, and logistical burdens on his family members that result from any single action or decision.

The central theme is that Rando feels an implicit pressure to take on responsibility for everyone's well-being and boundaries because he doesn't trust them to manage their own. This leads to a state of hyper-vigilance and contributes directly to his feelings of Guilt, Overwhelm, and Rage.

## 2. Implementation Methods

This system is not a single mechanic but a layer of pressure woven throughout the game. It is made tangible to the player through several methods:

### a. Internal Monologue (Primary Tool)
The primary way to make the cascade visible is through Rando's internal monologue. When a plan is proposed or an event occurs, the monologue will flash the chain of consequences on screen, allowing the player to understand the hidden costs of the decision.

- **Example (Airport Pickup):** When the Mother offers a ride, the monologue reveals the cost: *"Okay, but that's a four-hour round trip. Who's with Dad? Brother. He's going to be stuck there all afternoon. He'll be in a great mood later."*

- **Example (Grandmother Trip):** When the trip is proposed, the monologue becomes a rapid-fire calculation: *"If we go, Mom drives. Brother has to watch Dad. Dad will worry all night, so he'll be exhausted and irritable tomorrow. Sister has to be on backup call. It's a whole goddamn production."*

### b. "Mental Load" Status Effect
To represent the cognitive price of managing the cascade, a temporary UI status effect can be triggered. 

- **Label:** "Mental Load" or "Calculating..."
- **Effect:** While this status is active, the rate at which the **Overwhelm Meter** fills is temporarily increased. This effect would trigger during key decisions where Rando is actively trying to solve the emotional puzzle for his family.

### c. Consequence-Aware Dialogue Choices
Dialogue options should reflect Rando's awareness of the cascade. Choices should be less about a simple "yes/no" and more about how to navigate the web of dependencies.

- **Example (Proposing the Grandmother Trip):**
    - `[Enthusiastically Agree]` (Ignores the cascade, likely leading to failure and more Rage later).
    - `[Voice the Concern]` "Are we sure that's not too much to put on Brother?" (Acknowledges the cascade, may trigger a tense conversation).
    - `[Take Responsibility]` "Let me see if I can figure out a way to make it work without burdening everyone." (Puts the onus on Rando, activating the "Mental Load" effect).

### d. Environmental Storytelling
The player can also learn about the cascade through observation, such as overhearing a tense, sighed phone call between family members that reveals the stress a decision is causing them.

## 3. The Brother's "No" - A Major Narrative Beat

The collapse of the grandmother trip, caused by the brother enforcing his own boundary and saying "no," is a pivotal narrative moment. It serves as the ultimate failure state of the Responsibility Cascade.

- **Thematic Impact:** It proves Rando's core fear: if he doesn't manage and hold everything together, the system falls apart. This paradoxically validates his unhealthy coping mechanism of taking on all the responsibility.
- **Mechanical Impact:** This event should cause a significant spike in the **Reservoir** meter. Rando is forced to suppress his immense disappointment, his anger at the situation, and his profound guilt over the potential consequences for his grandmother. It is a key moment of bottling up complex, painful emotions.
