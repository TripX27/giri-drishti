/* 
 * =========================================================================================
 * GIRI-DRISHTI: HIGH-ALTITUDE COUNTER-UAS GIMBAL ASSEMBLY
 * Parametric OpenSCAD Model for Physical & Interference Validation
 *
 * Operational Elevation: 5,000 m ASL (540 mbar pressure / -55°C to +60°C)
 * Material: SiCp/Al Metal Matrix Composite (CTE = 6.5e-6 / K)
 * Clearance Protocol: IEC 60664-1 / IPC-2221C High-Altitude Derating (0.67 mm min gap)
 * =========================================================================================
 */

$fn = 60; // Render resolution smoothness

// --- PARAMETRIC SYSTEM DIMENSIONS (in mm) ---
yoke_span           = 170.0; // Distance between trunnion arm centers
yoke_arm_width      = 25.0;  // Arm cross-section width
yoke_arm_height     = 110.0; // Height from base motor to trunnion center
yoke_base_radius    = 60.0;  // Base flange radius
yoke_wall_thickness = 8.0;   // Structural wall thickness

// Optical Pod Payload
pod_radius          = 50.0;  // Spherical sensor pod radius
lens_aperture_rad   = 25.0;  // Optical lens clear aperture radius
lens_hood_length    = 15.0;  // Lens sunshade/hood depth

// Motor & Electrical Interface
azimuth_motor_rad   = 45.0;  // Direct-drive PMSM stator casing radius
azimuth_motor_h     = 30.0;  // Azimuth motor housing height
paschen_gap_min     = 0.67;  // IEC 60664-1 High-Altitude Creepage Gap (540 mbar)
pcb_ring_outer_rad  = 40.0;  // High-voltage motor drive PCB outer radius
pcb_ring_inner_rad  = 20.0;  // PCB inner clear bore

// Thermal Expansion Coefficients
temp_delta_cold     = -55.0 - 20.0; // -75 K delta from room temp
cte_sicp_al         = 6.5e-6;      // SiCp/Al MMC CTE (1/K)
thermal_shrinkage   = yoke_span * cte_sicp_al * abs(temp_delta_cold); // ~0.083 mm span delta

// --- MODULE DEFINITIONS ---

// 1. Azimuth Direct-Drive Motor Housing & Paschen Derated PCB Chamber
module AzimuthMotorBase() {
    color([0.3, 0.35, 0.4]) { // Dark Titanium Finish
        difference() {
            // Main Motor Casing
            cylinder(r=azimuth_motor_rad, h=azimuth_motor_h, center=false);
            
            // Hollow Stator Cavity
            translate([0, 0, 4])
                cylinder(r=azimuth_motor_rad - yoke_wall_thickness, h=azimuth_motor_h, center=false);
            
            // ePTFE Hydrophobic Breathing Vent Hole (MIL-STD-810H Method 500.6)
            translate([azimuth_motor_rad - 2, 0, azimuth_motor_h/2])
                rotate([0, 90, 0])
                    cylinder(r=4.0, h=10, center=true);
        }
    }
    
    // High-Voltage Motor Driver PCB with Paschen Derated Trace Clearance Ring
    translate([0, 0, 8]) {
        color([0.1, 0.6, 0.2, 0.9]) { // Green PCB
            difference() {
                cylinder(r=pcb_ring_outer_rad, h=2.0, center=false);
                cylinder(r=pcb_ring_inner_rad, h=3.0, center=true);
                
                // Paschen Dielectric Clearance Slots (0.67 mm width)
                for (angle = [0 : 45 : 315]) {
                    rotate([0, 0, angle])
                        translate([pcb_ring_inner_rad + 5, -paschen_gap_min/2, -0.5])
                            cube([12, paschen_gap_min, 3.0]);
                }
            }
        }
    }
}

// 2. SiCp/Al Metal Matrix Composite Yoke Frame
module SiCpAl_Yoke() {
    color([0.4, 0.45, 0.5]) { // SiCp/Al Composite Metallic Finish
        union() {
            // Base Ring Flange
            difference() {
                cylinder(r=yoke_base_radius, h=12, center=false);
                translate([0, 0, -1])
                    cylinder(r=yoke_base_radius - yoke_wall_thickness, h=15, center=false);
            }
            
            // Left Upright Arm
            translate([-yoke_span/2, -yoke_arm_width/2, 12]) {
                cube([yoke_arm_width, yoke_arm_width, yoke_arm_height]);
                // Trunnion Bearing Boss
                translate([yoke_arm_width/2, yoke_arm_width/2, yoke_arm_height])
                    rotate([0, 90, 0])
                        cylinder(r=18, h=yoke_arm_width, center=true);
            }
            
            // Right Upright Arm
            translate([yoke_span/2 - yoke_arm_width, -yoke_arm_width/2, 12]) {
                cube([yoke_arm_width, yoke_arm_width, yoke_arm_height]);
                // Trunnion Bearing Boss
                translate([yoke_arm_width/2, yoke_arm_width/2, yoke_arm_height])
                    rotate([0, 90, 0])
                        cylinder(r=18, h=yoke_arm_width, center=true);
            }
        }
    }
    
    // Sealed Low-Temperature Bearings (MIL-PRF-23827 Grease)
    color([0.85, 0.55, 0.1]) { // Amber Bronze Seal
        translate([-yoke_span/2 + yoke_arm_width/2, 0, 12 + yoke_arm_height])
            rotate([0, 90, 0])
                cylinder(r=15, h=12, center=true);
        
        translate([yoke_span/2 - yoke_arm_width/2, 0, 12 + yoke_arm_height])
            rotate([0, 90, 0])
                cylinder(r=15, h=12, center=true);
    }
}

// 3. Central Electro-Optical Sensor Pod Payload
module OpticalSensorPod(elevation_deg=0) {
    translate([0, 0, 12 + yoke_arm_height]) {
        rotate([elevation_deg, 0, 0]) { // Elevation Rotation Axis
            color([0.15, 0.35, 0.8, 0.9]) { // Anodized Blue Optical Casing
                difference() {
                    // Main Spherical Enclosure
                    sphere(r=pod_radius);
                    
                    // Internal Cavity for Optics & Camera
                    sphere(r=pod_radius - 5.0);
                    
                    // Front Lens Aperture Cutout
                    translate([0, pod_radius - 10, 0])
                        rotate([90, 0, 0])
                            cylinder(r=lens_aperture_rad, h=25, center=true);
                }
            }
            
            // Germanium / Sapphire Lens Window
            color([0.2, 0.8, 0.9, 0.6]) {
                translate([0, pod_radius - 6, 0])
                    rotate([90, 0, 0])
                        cylinder(r=lens_aperture_rad - 1.0, h=3.0, center=true);
            }
            
            // Lens Sunshade & Baffle
            color([0.1, 0.1, 0.15]) {
                translate([0, pod_radius + lens_hood_length/2 - 5, 0])
                    rotate([90, 0, 0])
                        difference() {
                            cylinder(r=lens_aperture_rad + 2.0, h=lens_hood_length, center=true);
                            cylinder(r=lens_aperture_rad, h=lens_hood_length + 2, center=true);
                        }
            }
        }
    }
}

// --- TOP-LEVEL ASSEMBLY INSTANTIATION ---
module Full_GiriDrishti_Gimbal_Assembly(azimuth_deg=25, elevation_deg=15) {
    rotate([0, 0, azimuth_deg]) { // Azimuth Rotation
        AzimuthMotorBase();
        SiCpAl_Yoke();
        OpticalSensorPod(elevation_deg=elevation_deg);
    }
}

// Render Complete Assembly
Full_GiriDrishti_Gimbal_Assembly(azimuth_deg=30, elevation_deg=15);

// --- OPENSCAD MECHANICAL METRICS LOG ---
echo("=================================================");
echo("GIRI-DRISHTI OPENSCAD VALIDATION PARAMETERS:");
echo("Yoke Material:", "SiCp/Al Metal Matrix Composite");
echo("Thermal Contraction @ -55C (mm):", thermal_shrinkage);
echo("Minimum Paschen PCB Gap (mm):", paschen_gap_min);
echo("Total Assembly Span (mm):", yoke_span);
echo("=================================================");
