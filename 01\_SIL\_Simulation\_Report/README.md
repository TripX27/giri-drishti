# 01: Software-in-the-Loop (SIL) Simulation Report

---

## 1. Simulation Overview & Technical Approach

As part of the rapid 36-hour build plan, a comprehensive Software-in-the-Loop (SIL) simulation was developed prior to hardware integration. The simulation environment was built to validate the stabilization control algorithms against complex mechanical and environmental disturbances before physical deployment.

The SIL architecture integrates:
* **Lagrange Gimbal Dynamics:** A highly accurate mathematical model of the 2-axis direct-drive gimbal, including inertia matrices, Coriolis effects, and gravitational terms.
* **GHOESO Control Loop:** A Generalized High-Order Extended State Observer (GHOESO) model designed to actively cancel real-world disturbances.
* **Simulated Target Tracking:** Emulation of the Line-Of-Sight (LOS) positioning error derived from the simulated EO/IR sensor feed.

The simulation was entirely constructed using **MATLAB/Simulink**.

---

## 2. Dynamic System Modeling

The simulation utilizes a Three-Mass Dynamic Gimbal Model that formulates the physical equations of the direct-drive gimbal assembly from the motor to the payload. 

This model actively simulates:
* **Mechanical Resonances:** Structural dynamics and vibrations of the gimbal yoke and arms.
* **Bearing Friction:** Modeled using dynamic non-linear friction models (e.g., LuGre/Stribeck) to account for stiction and Coulomb friction at sub-zero temperatures.
* **Cable Restraint Torques:** Simulating the non-linear flexural and torsional stiffness of the wiring harness.
* **Wind Shear:** Aerodynamic torque loads acting against the payload pod.

The combination of these elements forms the **total lumped disturbance ($d_{\text{total}}$)** that the control loop must continuously overcome.

---

## 3. Control Architecture: GHOESO

The core of the simulated control architecture is the **1 kHz GHOESO**. In the simulation, the observer continuously estimates the internal states of the system (position and velocity) alongside the lumped disturbance in real-time, using only the simulated control effort ($u$) and simulated encoder position ($y$).

By design, the estimated lumped disturbance is fed forward and actively subtracted from the control signal. This allows the simulation to prove the controller's ability to seamlessly cancel wind, stiction, and cable torque before they cause a line-of-sight tracking error.

---

## 4. Key Challenges & Resolutions during SIL

### 4.1 Observer Tuning Instability
**The Problem:** During initial SIL testing, the high-order ESO gains required for rapid disturbance rejection aggressively amplified simulated sensor noise (specifically from the modeled MEMS rate gyroscopes and encoders). This high-frequency noise injection caused severe instability and jitter in the simulated motor command output.

**The Solution:** This instability was resolved by introducing a **Tracking-Differentiator pre-filter** on the simulated gyro feedback before it was injected into the observer. This filter effectively smoothed the discontinuity behavior of the noise, ensuring the observer received clean state estimates without sacrificing the phase margin required for high-bandwidth control.

### 4.2 Compressed Timeline for Multi-Physics Coupling
**The Problem:** The 36-hour hackathon timeline was too compressed to create a unified co-simulation that simultaneously executed the mechanical control loop alongside the complex thermal and dielectric physics (such as Paschen avalanche breakdown and athermal optomechanical strain).

**The Solution:** The physics domains were decoupled. The athermalization (structural deformation) and Paschen derating (high-voltage clearance) problems were solved analytically via rigorous mathematical derivations. These results were then cross-checked against the real-time control simulation separately to ensure the system's control margins remained valid under the predicted physical deformations.
