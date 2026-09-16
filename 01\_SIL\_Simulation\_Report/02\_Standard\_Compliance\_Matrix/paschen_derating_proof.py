# =========================================================================
# PROOF 4: Paschen Dielectric Breakdown & High-Altitude MIL-STD Matrix
# Calculates Paschen Curve V_b(p·d) and IEC 60664-1 / IPC-2221C Derating
# =========================================================================

import numpy as np
import matplotlib.pyplot as plt

def calculate_paschen_breakdown():
    # Paschen Constants for dry air
    A = 15.0      # (cm·Torr)^-1
    B = 365.0    # V / (cm·Torr)
    gamma = 0.01 # Secondary electron emission coefficient

    # Pressure at 5,000m ASL
    P_5000m_mbar = 540.0
    P_5000m_Torr = P_5000m_mbar * 0.750062 # 405 Torr

    # Standard Sea-Level clearance vs 5,000m ASL derated clearance
    d_sea_level_cm = 0.045 # 0.45 mm IPC-2221C gap
    K_a_multiplier = 1.48 # IEC 60664-1 Table A.2 multiplier for 5,000m ASL
    d_derated_cm = d_sea_level_cm * K_a_multiplier # 0.666 mm (0.067 cm)

    pd_derated = P_5000m_Torr * d_derated_cm # 27.1 Torr·cm
    const_term = np.log(np.log(1.0 + 1.0/gamma))
    V_breakdown = (B * pd_derated) / (np.log(A * pd_derated) - const_term)

    V_peak_motor_bus = 580.0
    safety_margin = V_breakdown / V_peak_motor_bus

    print(f"5,000m ASL Atmospheric Pressure: {P_5000m_Torr:.1f} Torr ({P_5000m_mbar} mbar)")
    print(f"Base Trace Gap (IPC-2221C):      {d_sea_level_cm*10:.2f} mm")
    print(f"IEC 60664-1 Altitude Multiplier: {K_a_multiplier:.2f}x")
    print(f"Derated High-Altitude Gap:       {d_derated_cm*10:.2f} mm")
    print(f"Paschen Breakdown Voltage V_b:    {V_breakdown:.1f} V_peak")
    print(f"Operating Motor Driver Bus:      {V_peak_motor_bus:.1f} V_peak")
    print(f"Dielectric Safety Factor:        {safety_margin:.2f}x")

if __name__ == "__main__":
    calculate_paschen_breakdown()
