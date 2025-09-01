# Core Gameplay Loop & Systems

## 1. The Core Experience: A Cycle of Psychological Survival

The gameplay is built on a recurring cycle that represents the protagonist's internal struggle:

**Pressure -> Management -> Consequence**

1.  **Pressure:** The player is subjected to constant external pressures from the family system, the environment, and logistical challenges. This is embodied by the **Responsibility Cascade** system.

2.  **Management:** This pressure manifests as internal states the player must manage. The player's choices are not simply good or bad, but a complex ecosystem of psychological coping mechanisms.

3.  **Consequence:** The player's choices in managing their internal state have both immediate social outcomes and long-term psychological consequences, which are primarily reflected in the nightly **Dream Sequences**.

## 2. Modes of Emotional Management

Every major interaction is a choice between different strategies, each with a unique cost and benefit.

- **Connect (The Path to Healing):** This is the proactive choice to be vulnerable, honest, and direct. It is the most difficult path and can lead to immediate social friction, but it is the only way to fill the **Connection Meter** and achieve positive outcomes.

- **Active Suppression (The Emergency Valve):** This is a conscious, high-stakes decision to bottle up an overwhelming emotional surge. It is a timed mechanic that appears only when a meter like **Rage** is critically high. It prevents immediate social damage at the cost of significantly filling the **Reservoir Meter**.

- **Passive Avoidance (The Leaky Faucet):** This is the habitual, often unconscious, act of steering a conversation away from emotional topics. This is handled through dialogue choices that deflect, intellectualize, or give non-committal answers. This path seems safe, but it increases the **Overwhelm Meter**, representing the growing cognitive load of maintaining the avoidance and pushing the player closer to dissociation.

- **Rage Leak (The Failure State):** If the **Rage Meter** fills completely without being suppressed, the emotion bursts out as an involuntary sarcastic comment or sharp action, causing immediate social damage.

## 3. The Four Core Meters

These four meters represent the player's internal state and progress.

### a. The Rage Meter
- **Purpose:** Tracks immediate, in-the-moment frustration and anger.
- **Fills From:** Failed mini-games, frustrating interactions, triggering dialogue.
- **Management:** Can be drained by **Active Suppression**.

### b. The Reservoir Meter
- **Purpose:** Tracks the long-term, cumulative cost of bottling up emotions. It represents the weight of everything unsaid.
- **Fills From:** Primarily from acts of **Active Suppression**.
- **Consequence:** The higher the Reservoir, the more surreal and fragmented the nightly **Dream Sequences** become. It may also make it harder to choose **Connect** options over time.
- **Management:** Cannot be easily drained. May only be lowered through significant breakthroughs via the **Connection Meter**.

### c. The Overwhelm Meter
- **Purpose:** Tracks sensory and cognitive load from the environment and internal anxieties.
- **Fills From:** Physical clutter, excessive noise, the "Mental Load" of the **Responsibility Cascade**, and the cognitive dissonance from acts of **Passive Avoidance**.
- **Consequence:** This meter directly causes the **Dissociation** state.

### d. The Connection Meter
- **Purpose:** Tracks positive progress, moments of genuine vulnerability and healing.
- **Fills From:** Successfully choosing to **Connect**. Witnessing "Islands of Peace" (moments of genuine warmth between other family members).
- **Consequence:** Filling this meter is the game's primary "win" condition. It can unlock warmer dreams, create lasting positive changes in family dynamics, and slowly lower the **Reservoir**.

## 4. Key Systems & Mechanics

### a. Dissociation (Caused by Overwhelm)
Dissociation is not a meter, but a *state* triggered by the **Overwhelm Meter**.
- **Stage 1 (Overwhelm > 50%):** The "Emotional Weather" begins (see below). **Connect** dialogue options may flicker or appear visually unstable.
- **Stage 2 (Overwhelm > 90%):** The player is fully "Dissociated." **Connect** options disappear entirely, locking the player into safe/avoidant choices. To escape, a "grounding" action may be required.

### b. Emotional Weather (Environmental Feedback)
The game world visually and audibly reflects Rando's internal state.
- **High Overwhelm/Dissociation:** Colors become muted and desaturated. Ambient sounds become a low drone or are muffled. Hallways may appear to stretch longer.
- **High Rage:** A subtle red tint appears at the edges of the screen. The hum of an appliance may become louder and more aggressive.
- **High Connection:** A rare sunbeam may break through a window. The house may become quiet and peaceful for a moment.

### c. Responsibility Cascade
(See `planning/responsibility-cascade.md` for full details)
A pervasive system where the player is constantly aware of the chain of consequences their actions have on the family, creating a "Mental Load" that contributes to **Overwhelm**.

### d. The Avoidance Dilemma: Conflicting Values
This system introduces a core conflict between the protagonist's personal value of directness and the family's stated desire for avoidance.
- **The Setup:** The player is informed early on that specific family members (e.g., the siblings) have requested not to be engaged in heavy, emotional conversations.
- **The Conflict:** When a dialogue choice appears that would lead to a direct, "Connect"-style conversation, the player is caught in a dilemma. The internal monologue will highlight this conflict: *"They asked you not to. Is respecting their boundary the right thing to do, or is it a betrayal of my own integrity? Am I just using their request as an excuse to be avoidant myself?"*
- **The Consequence:** Choosing the "respectful" path of avoidance in these specific situations comes at a high price. It causes a large, immediate spike in the **Overwhelm Meter**. This models the intense internal dissonance of acting against one's own values, even for a seemingly noble reason. It is a direct path to dissociation.

### e. Dream Sequences
(See `planning/dream-sequences.md` for full details)
Nightly symbolic vignettes that reflect the player's choices and stats from the previous day. The player reflects on these dreams upon waking to gain small boons for the day ahead.

## 5. Future Development & Evolution

This section captures brainstorming and feedback for future mechanical and narrative development.

### a. Mechanical Evolution
- **Meter Consequences:** As the **Reservoir** and **Overwhelm** meters fill, **Connect** dialogue options should become more difficult to access. They might flicker, become visually unstable, require a faster reaction time to select, or be grayed out entirely, representing the reduced capacity for vulnerability when in a state of high internal stress.
- **Grief Meter:** The idea of a "Grief Meter" related to the sister's horse was considered and rejected. The protagonist's emotional journey should remain the central focus; he would not personally grieve this event, and the mechanic would feel inauthentic.

### b. Islands of Peace
These are small, player-initiated or observed moments of reprieve that can slightly lower the **Reservoir Meter** or provide other small boons.
- **Confirmed Ideas:**
    - Reading a book with his daughter.
    - Finding an old, positive memento from his own childhood.
- **Rejected Ideas:**
    - Watching his daughter sleep (not true to the experience).

### c. The "Rashomon" System
This is a potential late-game system, to be implemented only after the core narrative is established.
- **Concept:** After a significant emotional breakthrough (possibly unlocked by the "late-night conversation" with the Mother), the player gains the ability to replay pivotal, emotionally charged scenes from the perspective of other family members (Mother, Father, Brother, Sister).
- **Goal:** To provide the player with a deeper, more empathetic understanding of the family system and the motivations behind other characters' behaviors, moving beyond judgment and into a more complex understanding of their shared reality.
- **Implementation:** This would be a significant undertaking and should be considered an ambitious stretch goal or post-MVP feature.
