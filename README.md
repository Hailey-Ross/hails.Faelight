# ✨ hails.Faelight

A lightweight, reusable floating fairy-light marker for Second Life that highlights interactive spots using soft particles, motion, and color cycling.

Designed to draw attention without breaking immersion.

---

## 🌸 Features

- Proximity-based activation using `llSensorRepeat`
- Automatically hides when avatars are too close
- Smooth floating motion with gentle bobbing
- Twinkling particle effect with animated color cycling
- Designed to work without modifying existing objects
- Minimal setup and easy duplication across a sim

---

## 🌈 Visual Behavior

- Appears when an avatar is within range
- Disappears when the avatar is very close to the interaction spot
- Particles softly pulse and shift through complementary colors
- Motion and color work together to subtly draw attention

---

## 📦 Installation

1. Rez a small prim where you want to highlight an interaction spot  
2. Drop the script into the prim  
3. Optionally add a particle texture and set it in the script  
4. Position the prim slightly above or near the interaction area  

---

## ⚙️ Configuration

All key settings are located at the top of the script:

```lsl
float DETECTION_RADIUS = 6.0;
float HIDE_RADIUS = 1.2;
float SCAN_INTERVAL = 0.5;

float BOB_AMOUNT = 0.08;
float BOB_SPEED = 0.8;

float TWINKLE_SPEED = 1.2;
```

### Detection

```lsl
float DETECTION_RADIUS = 6.0;
```

Distance at which the marker becomes visible.

```lsl
float HIDE_RADIUS = 1.2;
```

Distance at which the marker hides again when avatars are very close.

---

### Motion

```lsl
float BOB_AMOUNT = 0.08;
float BOB_SPEED = 0.8;
```

Controls how much and how fast the marker floats up and down.

---

### Twinkle

```lsl
float TWINKLE_SPEED = 1.2;
```

Controls how quickly the color cycle and pulse effect runs.

---

## 🎨 Color System

The marker cycles through a palette of complementary colors designed to stand out in different environments.

```lsl
list colors = [
    <1.000, 0.72, 0.86>,
    <0.92, 0.70, 1.000>,
    <0.72, 0.86, 1.000>,
    <0.78, 1.000, 0.90>,
    <1.000, 0.86, 0.76>
];
```

You can customize this list to match your sim theme.

---

## ✨ Particle Settings

```lsl
string PARTICLE_TEXTURE = "";
```

Set this to a texture in the object inventory for improved visuals.

If left blank, the default particle is used.

---

## 🧩 Recommended Prim Setup

- Shape: Sphere  
- Size: Small such as `0.10 x 0.10 x 0.10`    
- Glow: Optional and subtle  
- Transparency: Full Transparency  

---

## 💡 Usage Tips

- Place slightly above or in front of the interaction area  
- Avoid placing directly inside dense meshes where particles may clip  
- Keep placement consistent across your sim to teach users the visual language  
- Works well for hidden or subtle interaction points like:  
  - Berry bushes  
  - Picnic spots  
  - Scenic overlooks  
  - Romantic seating areas  

---

## 🔧 Performance Notes

- Uses `llSensorRepeat` for efficient nearby avatar detection  
- Avoids scanning the entire region  
- Designed to scale well with multiple instances  

---

## 📜 License

Please retain all credits and comments within the script.
