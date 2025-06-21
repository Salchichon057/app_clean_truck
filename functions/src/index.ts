import { onCall } from "firebase-functions/v2/https";
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const createTruckDriver = onCall(async (request) => {
    console.log("createTruckDriver called", request.data);

    const { email, password, name, dni, phoneNumber } = request.data;

    if (!email || !password || !name || !dni || !phoneNumber) {
        console.error("Missing fields", request.data);
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Faltan campos obligatorios"
        );
    }

    try {
        // Crea el usuario en Auth SOLO con email y password
        const userRecord = await admin.auth().createUser({
            email,
            password,
            displayName: name,
        });

        // Guarda el teléfono en Firestore (como quieras)
        await admin.firestore().collection("app_users").doc(userRecord.uid).set({
            uid: userRecord.uid,
            name,
            email,
            dni,
            phoneNumber,
            role: "truck_driver",
            status: "active",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            location: { lat: -11.9498, long: -77.0622 },
            notificationPreferences: {
                daytimeAlerts: true,
                nighttimeAlerts: true,
                daytimeStart: "06:00",
                daytimeEnd: "20:00",
                nighttimeStart: "20:00",
                nighttimeEnd: "06:00",
            },
        });

        console.log("User created:", userRecord.uid);
        return { uid: userRecord.uid };
    } catch (error: any) {
        console.error("Error in createTruckDriver:", error);
        throw new functions.https.HttpsError(
            "internal",
            error.message ?? "Error desconocido"
        );
    }
});