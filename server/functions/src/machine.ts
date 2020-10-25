import {GuestUser, Machine} from "./types";
import {isEmptyObject} from "./utils";
import {logger} from "firebase-functions";

const functions = require('firebase-functions');
const admin = require('firebase-admin');

const getGuest = async (machineId: string): Promise<GuestUser | undefined> => {
  try {
    return (await admin.firestore()
      .collection('/guests')
      .doc(machineId)
      .get()).data() as unknown as GuestUser
  } catch (e) {
    logger.warn('Something happened when query a document in /guests.\n' + e)
    return undefined
  }
}

const isThisMachineRegisteredAGuestAccount = async (machineId: string): Promise<boolean> => {
  const guestUser = await getGuest(machineId)
  return !isEmptyObject(guestUser)
}

const createGuest = (position?: string): GuestUser => {
  // 1. generate a empty serialNumber.
  const serialNumber = ""
  
  // 2. create and return document.
  return {
    serialNumber,
    expire: -1, // use -1 to mark as a un-initialized guest account.
    reGenerateSerialNumberTime: 0,
    position: position ? position : 'unknown room',
    role: 'guest'
  } as GuestUser
}

export const onCreateMachine = functions.firestore.document('/NTUTLab321/{machineId}')
  .onCreate(async (change) => {
    const data = change.data() as Machine
    const machineId = change.id
    const machinePosition = data.judge
    
    // validate the data
    if (isEmptyObject(data) || !machinePosition) {
      logger.error('could not receive the new machine data pack!')
      return
    }
    
    // check if this machine is new to firebase.
    if (!(await isThisMachineRegisteredAGuestAccount(machineId))) {
      // generate a default config to guest collection (an empty guest account).
      const defaultGuestConfig = createGuest(machinePosition)
      
      // use this empty config to create a guest document.
      try {
        await admin.firestore()
          .collection('/guests')
          .doc(machineId)
          .set(defaultGuestConfig as GuestUser)
      } catch (e) {
        logger.error('could not create a guest document in /guests.\n' + e)
      }
    } else {
      logger.info(machineId + ' is already exist in /guest.')
    }
  })

export const onUpdateMachine = functions.firestore.document('/NTUTLab321/{machineId}')
  .onUpdate(async (change, context) => {
    const data = change.after.data() as Machine
    const machineId = change.after.id
    const machinePosition = data.judge
    
    // validate the data
    if (isEmptyObject(data) || !machinePosition) {
      logger.error('could not receive the new machine data pack!')
      return
    }
    
    // get the guest account that match to this machine.
    let guestDoc = await getGuest(machineId)
    if (isEmptyObject(guestDoc)) {
      logger.error(`there is a machine(${machineId}) that not have a guest account!`)
      return
    }
    
    // determine the machinePosition is equal to guestDoc's 'position' value.
    if (!('position' in guestDoc!) || machinePosition !== guestDoc?.position) {
      // update position.
      guestDoc!.position = machinePosition.toString().trim()
      
      // update document.
      try {
        await admin.firestore()
          .collection('/guests')
          .doc(machineId)
          .update(guestDoc as GuestUser)
      } catch (e) {
        logger.error('could not update a guest document in /guests.\n' + e)
      }
    }
  })
