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
// - Fades back to idle when nobody is nearby OR is interacting with the spot within the HIDE_RADIUS

float DETECTION_RADIUS = 6.0;
float HIDE_RADIUS = 1.2;
float SCAN_INTERVAL = 0.75;

float BOB_AMOUNT = 0.08;
float BOB_SPEED = 0.8;

float TWINKLE_SPEED = 1.2;

float ACTIVE_ALPHA = 0.00;
float IDLE_ALPHA = 0.00;

float ACTIVE_GLOW = 0.00;
float IDLE_GLOW = 0.00;

vector ACTIVE_COLOR = <1.000, 0.72, 0.86>;
vector IDLE_COLOR   = <0.78, 0.88, 1.000>;

string PARTICLE_TEXTURE = "";

integer gActive = FALSE;
vector gBasePos;
float gBobPhase = 0.0;
float gTwinklePhase = 0.0;

vector lerp(vector a, vector b, float t)
{
    return a + (b - a) * t;
}

vector getCycleColor(float phase)
{
    list colors = [
        <1.000, 0.72, 0.86>,
        <0.92, 0.70, 1.000>,
        <0.72, 0.86, 1.000>,
        <0.78, 1.000, 0.90>,
        <1.000, 0.86, 0.76>
    ];

    integer count = llGetListLength(colors);
    float wrapped = phase * (float)count;
    integer indexA = (integer)wrapped;
    float t = wrapped - (float)indexA;
    integer indexB = (indexA + 1) % count;

    vector colorA = llList2Vector(colors, indexA % count);
    vector colorB = llList2Vector(colors, indexB);

    return lerp(colorA, colorB, t);
}

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

list buildParticles(float phase)
{
    string texture = PARTICLE_TEXTURE;

    float cycle = (llSin(phase) + 1.0) * 0.5;
    vector startCol = getCycleColor(cycle);
    vector endCol = lerp(startCol, <0.78, 0.52, 0.70>, 0.20);

    float alpha = 0.3 + (0.18 * cycle);
    float size = 0.07 + (0.03 * cycle);

    return [
        PSYS_PART_FLAGS,
            PSYS_PART_EMISSIVE_MASK
            | PSYS_PART_INTERP_COLOR_MASK
            | PSYS_PART_INTERP_SCALE_MASK
            | PSYS_PART_FOLLOW_VELOCITY_MASK,

        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,

        PSYS_SRC_TEXTURE, texture,

        PSYS_PART_START_COLOR, startCol,
        PSYS_PART_END_COLOR, endCol,

        PSYS_PART_START_ALPHA, alpha,
        PSYS_PART_END_ALPHA, 0.00,

        PSYS_PART_START_SCALE, <size, size, 0.0>,
        PSYS_PART_END_SCALE, <0.02, 0.02, 0.0>,

        PSYS_PART_MAX_AGE, 2.0,

        PSYS_SRC_BURST_PART_COUNT, 2,
        PSYS_SRC_BURST_RATE, 0.15,

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

setParticles(float phase)
{
    llParticleSystem(buildParticles(phase));
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

    if (!gActive)
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

        llSensorRepeat("", NULL_KEY, AGENT, DETECTION_RADIUS, PI, SCAN_INTERVAL);
        llSetTimerEvent(SCAN_INTERVAL);
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
        integer i;
        integer shouldActivate = FALSE;
        vector myPos = llGetPos();

        for (i = 0; i < num_detected; ++i)
        {
            float dist = llVecDist(myPos, llDetectedPos(i));

            if (dist >= HIDE_RADIUS && dist <= DETECTION_RADIUS)
            {
                shouldActivate = TRUE;
                jump done;
            }
        }

@done;
        setActive(shouldActivate);
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

        if (gActive)
        {
            gTwinklePhase += SCAN_INTERVAL * TWINKLE_SPEED;
            if (gTwinklePhase > TWO_PI)
            {
                gTwinklePhase -= TWO_PI;
            }

            setParticles(gTwinklePhase);
        }
    }
}
