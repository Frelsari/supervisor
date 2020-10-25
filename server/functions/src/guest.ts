import {Request} from "firebase-functions/lib/providers/https";
import {
  RequirementOfReGenerateSerialNumber,
  RequirementOfQueryAllGuest,
  GuestUser,
  RequirementOfDeleteSpecificGuest
} from "./types";
import {
  decryptJwt,
  getRandomSerial,
  isEmptyObject,
  reGenerateSerialNumberDurationTime,
  validatePermissionAndGetDocument
} from "./utils";

const functions = require('firebase-functions');
const admin = require('firebase-admin');

export default functions.https.onRequest(async (req: Request, resp) => {

  const modifyGuestSerialNumber = async (machine: string, guestUser: GuestUser, expire: number) => {
    guestUser.expire = expire
    guestUser.serialNumber = getRandomSerial(6)
    guestUser.reGenerateSerialNumberTime = Date.now() + reGenerateSerialNumberDurationTime
    await admin.firestore()
      .collection('/guests')
      .doc(machine)
      .update(guestUser)
  }
  
  const authJwt = async (jwt: string): Promise<string> => {
    // auth jwt
    const decodedToken = await decryptJwt(jwt)
    if (!decodedToken) {
      resp.status(401).send('Invalid jwt token.')
      (() => {
        throw new Error()
      })()
    }
    
    // validate permission
    let document = (await validatePermissionAndGetDocument(decodedToken!.uid, ['administrator', 'staff']))
    if (!document) {
      resp.status(403).send('Insufficient permission, access denied.')
      (() => {
        throw new Error()
      })()
    }
    return document['role']
  }
  
  if (req.method === 'POST') {
    const data = req.body as unknown as RequirementOfReGenerateSerialNumber
    
    // check if the request body is correct.
    if (!data || !data.jwtToken || !data.expire || !data.machine) {
      resp.status(400).send('Incorrect request format or lack of necessary information!')
      return
    }
    
    // auth
    let permission!: string
    try {
      permission = await authJwt(data.jwtToken)
    } catch (e) {
      return
    }
    
    // pre-fix request data.
    data.machine = data.machine.trim()
    data.expire = Number(data.expire)
    if (Number.isNaN(data.expire)) {
      resp.status(400).send('Incorrect request format!')
    }
    
    // check if this machine is already bind a account, if so, get the user data, else, create new user data.
    let guestUser: GuestUser | undefined
    // let isAlreadyExist = true
    try {
      guestUser = (await admin.firestore()
        .collection('/guests')
        .doc(data.machine)
        .get()).data() as unknown as GuestUser
      
      if (!guestUser || isEmptyObject(guestUser)) {
        resp.status(404).send('Unable to find this machine.')
        return
        
      } else if (permission === 'administrator' || Date.now() > guestUser.reGenerateSerialNumberTime) {
        try {
          await modifyGuestSerialNumber(data.machine, guestUser, data.expire)
        } catch (e) {
          resp.status(500).send('Internal error when trying to modify serial number.')
          return
        }
      } else {
        resp.status(403).send('Please wait for this operation again.')
        return
      }
    } catch (e) {
      resp.status(500).send('Unable to create user, process errored.')
      return
    }
    
    resp.status(202).json(
      {
        message: 'Successfully regenerated a new serial number.',
        guestData: {
          machine: data.machine,
          ...guestUser
        }
      }
    )
    return
  }
  
  if (req.method === 'GET') {
    const data = req.query as unknown as RequirementOfQueryAllGuest
    
    // check if the request body is correct.
    if (!data || !data.jwtToken) {
      resp.status(400).send('Incorrect request format or lack of necessary information!')
      return
    }
    
    // auth
    try {
      await authJwt(data.jwtToken)
    } catch (e) {
      return
    }
    
    // get all guests
    try {
      const guests = (await admin.firestore().collection('guests').get()).docs
        .map(guest => Object.assign({machine: guest.id}, guest.data()))
      resp.status(200).json([...guests])
      return
    } catch (e) {
      resp.status(500).json(
        {
          result: 'Unable to get staffs in firestore',
          messages: e
        }
      )
    }
  }
  
  if (req.method === 'DELETE') {
    const data = req.query as unknown as RequirementOfDeleteSpecificGuest
  
    // check if the request body is correct.
    if (!data || !data.jwtToken || !data.machine) {
      resp.status(400).send('Incorrect request format or lack of necessary information!')
      return
    }
  
    // auth
    try {
      await authJwt(data.jwtToken)
    } catch (e) {
      return
    }
  
    // delete staffs
    try {
      await admin.firestore().collection('guests').doc(data.machine).delete()
      await admin.firestore().collection('NTUTLab321').doc(data.machine).delete()
      resp.status(200).json(
        {
          message: 'Successfully unregister the machine and remove the guest user.',
          machine: data.machine
        }
      )
      return
    } catch (e) {
      resp.status(500).json(
        {
          result: 'Unable to unregister the machine in firestore',
          messages: e
        }
      )
      return
    }
  }
  
  resp.status(405).send('Invalid request method!')
  return
})
