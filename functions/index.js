const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const axios = require("axios");
const admin = require("firebase-admin");

// Initialize Firebase Admin if not already done
if (!admin.apps.length) {
  admin.initializeApp();
}

// Optional: limit scaling
setGlobalOptions({ maxInstances: 10 });

const db = admin.firestore();

// ============================================================================
// NEARBY HOSPITALS (Google Maps API)
// ============================================================================
exports.nearbyHospitals = onRequest(async (req, res) => {
  try {
    const { lat, lng } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: "Missing coordinates" });
    }

    const response = await axios.get(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json",
      {
        params: {
          location: `${lat},${lng}`,
          radius: 3500,
          type: "hospital",
          key: process.env.GOOGLE_API_KEY,
        },
      }
    );

    res.status(200).json(response.data);
  } catch (error) {
    logger.error("Hospital fetch error:", error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================================
// DELETE USER AUTH ACCOUNT
// ============================================================================
exports.deleteUserAuthAccount = onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  try {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed. Use POST." });
    }

    const { uid, email } = req.body;

    if (!uid) {
      return res.status(400).json({ error: "Missing required field: uid" });
    }

    logger.info(
      `Starting deletion of auth account for UID: ${uid}, Email: ${email}`
    );
    await admin.auth().deleteUser(uid);
    logger.info(
      `✅ Successfully deleted Firebase Auth account - UID: ${uid}, Email: ${email}`
    );

    return res.status(200).json({
      success: true,
      message: `Firebase Auth account deleted for UID: ${uid}`,
      uid: uid,
      email: email,
    });
  } catch (error) {
    logger.error(`❌ Error deleting Firebase Auth account:`, error);

    if (error.code === "auth/user-not-found") {
      logger.info(
        `User not found in Firebase Auth (may have been deleted already)`
      );
      return res.status(200).json({
        success: true,
        message: "User not found in Firebase Auth (may already be deleted)",
      });
    }

    return res.status(500).json({
      success: false,
      error: error.message,
      code: error.code,
    });
  }
});

// ============================================================================
// SEED DATABASE (Hospital Portal)
// ============================================================================
exports.seedDatabase = onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  try {
    const appointmentsSnapshot = await db
      .collection("appointments")
      .limit(1)
      .get();

    if (!appointmentsSnapshot.empty) {
      return res.status(200).json({
        message: "Database already seeded",
        seeded: false,
      });
    }

    // Create departments first
    const departments = {};
    const deptNames = ["Cardiology", "Orthopedics", "ENT", "Neurology"];

    for (const deptName of deptNames) {
      const deptRef = await db.collection("departments").add({
        name: deptName,
        createdAt: admin.firestore.Timestamp.now(),
      });
      departments[deptName] = deptRef.id;
    }

    logger.info("Departments created:", departments);

    // Create hospital 1
    const hospital1 = await db.collection("hospitals").add({
      name: "City Care Hospital",
      address: "Kochi, Kerala",
      phone: "9876543210",
      email: "citycare@gmail.com",
      status: "approved",
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    // Create doctors for hospital 1
    await db.collection("doctors").add({
      hospitalId: hospital1.id,
      name: "Dr. John",
      departmentId: departments["Cardiology"],
      consultationStart: "09:00",
      consultationEnd: "17:00",
      experienceYears: 10,
      isAvailable: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    await db.collection("doctors").add({
      hospitalId: hospital1.id,
      name: "Dr. Mary",
      departmentId: departments["Orthopedics"],
      consultationStart: "10:00",
      consultationEnd: "18:00",
      experienceYears: 8,
      isAvailable: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    // Create hospital 2
    const hospital2 = await db.collection("hospitals").add({
      name: "Green Valley Hospital",
      address: "Ernakulam, Kerala",
      phone: "9123456780",
      email: "greenvalley@gmail.com",
      status: "approved",
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    // Create doctor for hospital 2
    await db.collection("doctors").add({
      hospitalId: hospital2.id,
      name: "Dr. Rahul",
      departmentId: departments["ENT"],
      consultationStart: "10:00",
      consultationEnd: "18:00",
      experienceYears: 12,
      isAvailable: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    // Create appointments
    await db.collection("appointments").add({
      userId: "sampleUser1",
      hospitalId: hospital1.id,
      patientName: "Arun Kumar",
      phone: "9000000001",
      preferredDate: "2026-03-01",
      description: "Chest pain consultation",
      status: "pending",
      createdAt: admin.firestore.Timestamp.now(),
    });

    await db.collection("appointments").add({
      userId: "sampleUser2",
      hospitalId: hospital1.id,
      patientName: "Meera S",
      phone: "9000000002",
      preferredDate: "2026-03-02",
      description: "Orthopedic review",
      status: "approved",
      createdAt: admin.firestore.Timestamp.now(),
    });

    await db.collection("appointments").add({
      userId: "sampleUser3",
      hospitalId: hospital2.id,
      patientName: "Rahul P",
      phone: "9000000003",
      preferredDate: "2026-03-03",
      description: "ENT checkup",
      status: "pending",
      createdAt: admin.firestore.Timestamp.now(),
    });

    logger.info("Database seeded successfully");
    res.status(200).json({
      message: "Database seeded successfully",
      seeded: true,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Error seeding database:", error);
    res.status(500).json({
      error: error.message,
      message: "Failed to seed database",
    });
  }
});
