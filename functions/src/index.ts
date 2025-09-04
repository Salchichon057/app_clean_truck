import { onCall } from "firebase-functions/v2/https";
// import { onDocumentWritten } from "firebase-functions/v2/firestore"; // No longer needed
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Función para crear un conductor de camión
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
		const userRecord = await admin.auth().createUser({
			email,
			password,
			displayName: name,
		});

		await admin.firestore().collection("app_users").doc(userRecord.uid).set({
			uid: userRecord.uid,
			name,
			email,
			dni,
			phone_number: phoneNumber,
			role: "truck_driver",
			status: "active",
			created_at: admin.firestore.FieldValue.serverTimestamp(),
			location: { lat: -11.9498, long: -77.0622 },
			notification_preferences: {
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
