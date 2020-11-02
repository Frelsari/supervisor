import {Request} from "firebase-functions/lib/providers/https";
import {RequirementOfQuerySpecificUser, GuestUser, Machine} from "./types";
import {decryptJwt, isEmptyObject, validatePermissionAndGetDocument} from "./utils";
import {getMachineData} from "./machine";

const functions = require('firebase-functions');
const admin = require('firebase-admin');

export default functions.https.onRequest(async (req: Request, resp) => {
  if (req.method === 'GET') {
    const data = req.query as unknown as RequirementOfQuerySpecificUser
    
    // check if the request body is correct.
    if (!data ||
      (!data.jwtToken && !data.serialNumber && !data.uid) ||
      (data.jwtToken && data.serialNumber && data.uid) ||
      (!data.jwtToken && !data.serialNumber && data.uid) ||
      (!data.jwtToken && data.serialNumber && data.uid)
    ) {
      resp.status(400).send('Incorrect request format or lack of necessary information!')
      return
    }
    
    if (!data.serialNumber && data.jwtToken) {
      // auth jwt
      const decodedToken = await decryptJwt(data.jwtToken)
      if (!decodedToken) {
        resp.status(401).send('Invalid jwt token.')
        return
      }
      
      // validate permission and find the document.
      const userDocument = await validatePermissionAndGetDocument(decodedToken!.uid, ['administrator', 'staff'])
      if (isEmptyObject(userDocument)) {
        resp.status(403).send('Permission validation failed, access denied.')
        return
      }
      const role = userDocument!['role']
      
      // A => only jwt
      if (!data.uid) {
        resp.status(200).json(Object.assign({uid: decodedToken!.uid}, userDocument))
        return
      }
      
      // C => jwt and uid
      if (data.uid) {
        if (role !== 'administrator') {
          resp.status(403).send('Permission validation failed, access denied.')
          return
        }
        // validate permission and find the document.
        const staffDocument = await validatePermissionAndGetDocument(data.uid, ['staff'])
        if (isEmptyObject(staffDocument)) {
          resp.status(404).send('Could not find the user data by this uid.')
          return
        }
        resp.status(200).json(Object.assign({uid: data.uid}, staffDocument))
        return
      }
    } else if (data.serialNumber) {
      
      let guestDocument!: GuestUser
      let guestDocumentId!: string
      (await admin.firestore()
        .collection('guests')
        .where('serialNumber', '==', data.serialNumber).get())
        .forEach(doc => {
          guestDocument = doc.data()
          guestDocumentId = doc.id
        })
      
      if (!guestDocument || !guestDocumentId || isEmptyObject(guestDocument)) {
        resp.status(404).send('Could not find the user data by this serialNumber.')
        return
      }
      
      let isStaffOrAdmin = false
      if (data.jwtToken) {
        // auth jwt
        const decodedToken = await decryptJwt(data.jwtToken)
        if (decodedToken) {
          // validate permission and find the document.
          const userDocument = await validatePermissionAndGetDocument(decodedToken!.uid, ['administrator', 'staff'])
          isStaffOrAdmin = !isEmptyObject(userDocument)
        }
      }
      
      // check if expired.
      if (!isStaffOrAdmin && guestDocument.expire < Date.now()) {
        // B => only serialNumber
        resp.status(410).send('This account has expired.')
        return
      }
      
      // get machineData.
      const machineData = await getMachineData(guestDocumentId) as Machine
      if (isEmptyObject(machineData)) {
        resp.status(404).send('Could not find the machine data by this machineId.')
        return
      }
      
      // D => jwt and serialNumber
      resp.status(200).json(
        {
          ...{machine: guestDocumentId},
          machineData,
          guestDocument
        }
      )
      return
      
    } else {
      resp.status(400).send('Incorrect request format.')
      return
    }
  }
  
  resp.status(405).send('Invalid request method!')
  return
})
