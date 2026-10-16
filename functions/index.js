const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.password,
  },
});

exports.enviarReportePorCorreo = functions.firestore
  .document("reportes/{reporteId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const mailOptions = {
      from: `"CuidaConecta" <${functions.config().email.user}>`,
      to: "liliana.valverde.hh@gmail.com",
      subject: "Nuevo reporte en CuidaConecta",
      text: `
Se ha enviado un nuevo reporte.

Reportante ID: ${data.reportanteId}
Evaluado: ${data.nombreEvaluado}
Evaluado ID: ${data.evaluadoId}
Solicitud ID: ${data.solicitudId}
Rol reportante: ${data.rolReportante}

Motivo:
${data.motivo}
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log("Correo enviado correctamente");
    } catch (error) {
      console.error("Error enviando correo:", error);
    }
  });
