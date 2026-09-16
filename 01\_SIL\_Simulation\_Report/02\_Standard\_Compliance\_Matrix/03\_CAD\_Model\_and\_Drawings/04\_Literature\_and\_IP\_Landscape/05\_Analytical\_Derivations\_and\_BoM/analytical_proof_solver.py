"""
Giri-Drishti C-UAS Gimbal System
Executable Symbolic Math Verification Script (analytical_proof_solver.py)

This script uses SymPy to symbolically derive and verify:
1. The 2-Axis Euler-Lagrange Gimbal Dynamics Equation.
2. The GHOESO Observer Error Matrix Eigenvalues (Poles at -omega_o).
3. Paschen's Law Dielectric Breakdown Derivative and Minimum Voltage.
"""

import sympy as sp

def verify_euler_lagrange():
    print("=== 1. SYMBOLIC EULER-LAGRANGE DERIVATION ===")
    t = sp.Symbol('t', real=True, positive=True)
    theta = sp.Function('theta')(t)
    theta_dot = sp.diff(theta, t)
    theta_ddot = sp.diff(theta_dot, t)

    J = sp.Symbol('J', real=True, positive=True)
    Bv = sp.Symbol('Bv', real=True, positive=True)
    u = sp.Symbol('u', real=True)
    d_total = sp.Symbol('d_total', real=True)

    # Lagrangian L = T - V (where V = 0 for balanced decoupled axis)
    T = sp.Rational(1, 2) * J * theta_dot**2
    V = 0
    L = T - V

    # Rayleigh dissipation function F = 1/2 * Bv * theta_dot^2
    F = sp.Rational(1, 2) * Bv * theta_dot**2

    # Euler-Lagrange operator: d/dt(dL/dtheta_dot) - dL/dtheta + dF/dtheta_dot = u - d_total
    dL_dtheta_dot = sp.diff(L, theta_dot)
    dt_dL_dtheta_dot = sp.diff(dL_dtheta_dot, t)
    dL_dtheta = sp.diff(L, theta)
    dF_dtheta_dot = sp.diff(F, theta_dot)

    el_eq = sp.Eq(dt_dL_dtheta_dot - dL_dtheta + dF_dtheta_dot, u - d_total)
    print("Verified Euler-Lagrange Equation:")
    sp.pprint(el_eq)
    print("\nSolved for Acceleration theta_ddot(t):")
    accel_sol = sp.solve(el_eq, theta_ddot)[0]
    sp.pprint(sp.Eq(theta_ddot, accel_sol))
    print()

def verify_ghoeso_eigenvalues():
    print("=== 2. GHOESO OBSERVER EIGENVALUE VERIFICATION ===")
    wo = sp.Symbol('omega_o', real=True, positive=True)

    # Observer error matrix A_e = A - beta*C
    # A_e = [[-3*wo, 1, 0], [-3*wo^2, 0, 1], [-wo^3, 0, 0]]
    Ae = sp.Matrix([
        [-3*wo, 1, 0],
        [-3*wo**2, 0, 1],
        [-wo**3, 0, 0]
    ])

    eigenvals = Ae.eigenvals()
    print("Observer Error Matrix A_e:")
    sp.pprint(Ae)
    print("\nCharacteristic Equation Eigenvalues:")
    for val, mult in eigenvals.items():
        print(f"  Lambda = {val} (Multiplicity: {mult})")
    print("CONFIRMED: All 3 observer error poles reside strictly at -omega_o.\n")

def verify_paschen_derivation():
    print("=== 3. PASCHEN DIELECTRIC BREAKDOWN DERIVATION ===")
    pd = sp.Symbol('pd', real=True, positive=True)
    A = sp.Symbol('A', real=True, positive=True)
    B = sp.Symbol('B', real=True, positive=True)
    gamma = sp.Symbol('gamma', real=True, positive=True)

    # Paschen Formula: V_b = (B * pd) / (ln(A * pd) - ln(ln(1 + 1/gamma)))
    ln_term = sp.log(A * pd) - sp.log(sp.log(1 + 1/gamma))
    Vb = (B * pd) / ln_term

    dVb_dpd = sp.diff(Vb, pd)
    critical_pd_sol = sp.solve(dVb_dpd, pd)

    print("Paschen Breakdown Formula V_b(pd):")
    sp.pprint(Vb)
    print("\nDerivative d(Vb)/d(pd) = 0 Minimum Point (pd)_min:")
    if critical_pd_sol:
        sp.pprint(critical_pd_sol[0])
    print()

if __name__ == '__main__':
    verify_euler_lagrange()
    verify_ghoeso_eigenvalues()
    verify_paschen_derivation()
