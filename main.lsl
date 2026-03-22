//Script Created by Hailey Enfield
//Site: https://links.hails.cc
//Github: https://github.com/Hailey-Ross/hails.Faelight
//PLEASE LEAVE ALL CREDITS/COMMENTS INTACT

// hails.FaeLight
// Floating fairy-light style proximity marker
// Drop into a small prim and place near a spot you would like to bring attention to.

// Optional setup:
// - Put a particle texture in inventory and set PARTICLE_TEXTURE below
// - You can leave PARTICLE_TEXTURE blank to use the default particle

// This script:
// - Detects avatars in range
// - Turns particles on when someone is nearby
// - Gently bobs the prim up and down
// - Fades back to idle when nobody is nearby

float DETECTION_RADIUS = 6.0;
float DETECTION_ARC = PI;
float SCAN_INTERVAL = 2.0;

float BOB_AMOUNT = 0.08;         // How far up/down it moves
float BOB_SPEED = 0.8;           // Higher = faster bob

float ACTIVE_ALPHA = 0.00;       // Visible when someone is nearby
float IDLE_ALPHA = 0.00;         // visible when idle?

float ACTIVE_GLOW = 0.00;
float IDLE_GLOW = 0.00;

vector ACTIVE_COLOR = <1.000, 0.72, 0.86>;
vector IDLE_COLOR   = <0.78, 0.88, 1.000>;

string PARTICLE_TEXTURE = "";    // Set to texture name if you add one

integer gActive = FALSE;
vector gBasePos;
float gBobPhase = 0.0;

updateVisuals()
{
    if (gActive)
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_COLOR, ALL_SIDES, ACTIVE_COLOR, ACTIVE_ALPHA,
            PRIM_GLOW, ALL_SIDES, ACTIVE_GLOW,
            PRIM_FULLBRIGHT, ALL_SIDES, TRUE
        ]);
    }
    else
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_COLOR, ALL_SIDES, IDLE_COLOR, IDLE_ALPHA,
            PRIM_GLOW, ALL_SIDES, IDLE_GLOW,
            PRIM_FULLBRIGHT, ALL_SIDES, TRUE
        ]);
    }
}

list buildParticles()
{
    string texture = PARTICLE_TEXTURE;

    return [
        PSYS_PART_FLAGS,
            PSYS_PART_EMISSIVE_MASK
            | PSYS_PART_INTERP_COLOR_MASK
            | PSYS_PART_INTERP_SCALE_MASK
            | PSYS_PART_FOLLOW_VELOCITY_MASK,

        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,

        PSYS_SRC_TEXTURE, texture,

        PSYS_PART_START_COLOR, <1.000, 0.76, 0.88>,
        PSYS_PART_END_COLOR,   <0.80, 0.90, 1.000>,

        PSYS_PART_START_ALPHA, 0.30,
        PSYS_PART_END_ALPHA,   0.00,

        PSYS_PART_START_SCALE, <0.08, 0.08, 0.0>,
        PSYS_PART_END_SCALE,   <0.02, 0.02, 0.0>,

        PSYS_PART_MAX_AGE, 2.4,

        PSYS_SRC_BURST_PART_COUNT, 3,
        PSYS_SRC_BURST_RATE, 0.18,

        PSYS_SRC_ACCEL, <0.0, 0.0, 0.03>,
        PSYS_SRC_BURST_SPEED_MIN, 0.01,
        PSYS_SRC_BURST_SPEED_MAX, 0.05,

        PSYS_SRC_ANGLE_BEGIN, 0.00,
        PSYS_SRC_ANGLE_END, 0.45,

        PSYS_SRC_MAX_AGE, 0.0,

        PSYS_SRC_BURST_RADIUS, 0.03,
        PSYS_SRC_OMEGA, <0.0, 0.0, 0.2>
    ];
}

startParticles()
{
    llParticleSystem(buildParticles());
}

stopParticles()
{
    llParticleSystem([]);
}

setActive(integer active)
{
    if (gActive == active)
    {
        return;
    }

    gActive = active;
    updateVisuals();

    if (gActive)
    {
        startParticles();
    }
    else
    {
        stopParticles();
    }
}

default
{
    state_entry()
    {
        gBasePos = llGetLocalPos();

        llSetStatus(STATUS_PHYSICS, FALSE);
        llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y | STATUS_ROTATE_Z, FALSE);

        updateVisuals();
        stopParticles();

        llSensorRepeat("", NULL_KEY, AGENT, DETECTION_RADIUS, DETECTION_ARC, SCAN_INTERVAL);
        llSetTimerEvent(0.1);
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if (change & CHANGED_REGION_START)
        {
            llResetScript();
        }
        else if (change & CHANGED_LINK)
        {
            gBasePos = llGetLocalPos();
        }
    }

    sensor(integer num_detected)
    {
        if (num_detected > 0)
        {
            setActive(TRUE);
        }
    }

    no_sensor()
    {
        setActive(FALSE);
    }

    timer()
    {
        gBobPhase += 0.1 * BOB_SPEED;
        if (gBobPhase > TWO_PI)
        {
            gBobPhase -= TWO_PI;
        }

        float offset = llSin(gBobPhase) * BOB_AMOUNT;
        vector pos = gBasePos + <0.0, 0.0, offset>;

        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_POS_LOCAL, pos
        ]);
    }
}
