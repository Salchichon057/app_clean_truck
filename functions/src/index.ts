import { onCall } from "firebase-functions/v2/https";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
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

export const notifyCitizensWhenTruckIsNear = onDocumentWritten(
	"app_users/{userId}",
	async (event) => {
		const after = event.data?.after?.data();
		if (!after) return;

		if (after.role !== 'truck_driver' || !after.location) return;

		const conductorUid = after.uid;
		const truckSnap = await admin.firestore().collection('trucks')
			.where('id_app_user', '==', conductorUid)
			.limit(1)
			.get();

		if (truckSnap.empty) return;
		const truck = truckSnap.docs[0].data();
		const truckId = truck.idTruck;

		const routeSnap = await admin.firestore().collection('routes')
			.where('id_truck', '==', truckId)
			.where('status', '==', 'active')
			.limit(1)
			.get();

		if (routeSnap.empty) return;
		const route = routeSnap.docs[0].data();
		const currentRouteId = route.uid;

		const truckLat = after.location.lat;
		const truckLong = after.location.long;

		const usersSnap = await admin.firestore().collection('app_users')
			.where('role', '==', 'citizen')
			.where('selectedRouteId', '==', currentRouteId)
			.get();

		const notifications: Promise<any>[] = [];
		const now = admin.firestore.Timestamp.now();

		usersSnap.forEach(async doc => {
			const user = doc.data();
			if (!user.location || !user.fcmToken) return;

			const userLat = user.location.lat;
			const userLong = user.location.long;

			const distance = getDistanceFromLatLonInMeters(truckLat, truckLong, userLat, userLong);

			if (distance <= 200) {
				// Verifica si ya se notificó en los últimos 3 minutos
				const notificationsRef = admin.firestore()
					.collection('app_users')
					.doc(doc.id)
					.collection('notifications');

				const recentNotifSnap = await notificationsRef
					.where('type', '==', 'truck_near')
					.where('routeId', '==', currentRouteId)
					.orderBy('timestamp', 'desc')
					.limit(1)
					.get();

				let shouldSend = true;
				if (!recentNotifSnap.empty) {
					const lastNotif = recentNotifSnap.docs[0].data();
					const lastTimestamp = lastNotif.timestamp?.toDate();
					if (lastTimestamp && (now.toDate().getTime() - lastTimestamp.getTime()) < 3 * 60 * 1000) {
						shouldSend = false;
					}
				}

				if (shouldSend) {
					const payload = {
						notification: {
							title: "¡El camión está cerca!",
							body: "El camión de basura está a menos de 200 metros de tu ubicación.",
						},
						data: {
							truckId: truckId,
							routeId: currentRouteId,
							distance: distance.toFixed(0),
						}
					};
					notifications.push(
						admin.messaging().sendToDevice(user.fcmToken, payload)
					);

					// También guarda la notificación en Firestore
					const notificationDoc = notificationsRef.doc();
					notifications.push(
						notificationDoc.set({
							uid: notificationDoc.id,
							type: 'truck_near',
							routeId: currentRouteId,
							message: "El camión de basura está a menos de 200 metros de tu ubicación.",
							timestamp: now,
							read: false,
						})
					);
				}
			}
		});

		await Promise.all(notifications);
		return null;
	}
);

// Haversine formula para calcular distancia entre dos puntos (en metros)
function getDistanceFromLatLonInMeters(lat1: number, lon1: number, lat2: number, lon2: number) {
	const R = 6371000;
	const dLat = (lat2 - lat1) * Math.PI / 180;
	const dLon = (lon2 - lon1) * Math.PI / 180;
	const a =
		Math.sin(dLat / 2) * Math.sin(dLat / 2) +
		Math.cos(lat1 * Math.PI / 180) *
		Math.cos(lat2 * Math.PI / 180) *
		Math.sin(dLon / 2) * Math.sin(dLon / 2);
	const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	return R * c;
}