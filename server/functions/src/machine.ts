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

const generateNewGuestData = (position?: string): GuestUser => {
  // 1. generate a empty serialNumber.
  const serialNumber = ""
  
  // 2. create and return document.
  return {
    serialNumber,
    expire: -1, // use -1 to mark as a un-initialized guest account.
    reGenerateSerialNumberTime: 0,
    position: position ? position : 'unknown',
    role: 'guest'
  } as GuestUser
}

const createNewGuest = async (machinePosition: string, machineId: string): Promise<void> => {
  // generate a default config to guest collection (an empty guest account).
  const newGuestData = generateNewGuestData(machinePosition)
  
  // use this empty config to create a guest document.
  try {
    await admin.firestore()
      .collection('/guests')
      .doc(machineId)
      .set(newGuestData as GuestUser)
  } catch (e) {
    logger.error('could not create a guest document in /guests.\n' + e)
  }
}

export const getMachineData = async (machineId: string): Promise<Machine | undefined> => {
  try {
    const machineData = (await admin.firestore()
      .collection('NTUTLab321')
      .doc(machineId.toString().trim())
      .get()).data() as unknown as Machine
    
    // detect schema version.
    if (!('judge' in machineData)) {
      if ('title' in machineData) {
        machineData.judge = machineData.title
      } else {
        machineData.judge = "unknown"
      }
    }
    
    // remove title property anyway.
    if ('title' in machineData) {
      delete machineData.title
    }
    
    return machineData
  } catch (e) {
    logger.warn(`Could not get the machine data! request machineId(${machineId}) may not exist.`)
    return undefined
  }
}


export const onCreateMachine = functions.firestore.document('/NTUTLab321/{machineId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data() as Machine
    const machineId = snapshot.id
    const machinePosition = data.judge ?? data.title
    
    // validate the data
    if (isEmptyObject(data) || !machinePosition) {
      logger.error('could not receive the new machine data pack!')
      return
    }
    
    // check if this machine is new to firebase.
    if (!(await isThisMachineRegisteredAGuestAccount(machineId))) {
      await createNewGuest(machinePosition, machineId)
    } else {
      logger.info(machineId + ' is already exist in guest collection.')
    }
  })

export const onUpdateMachine = functions.firestore.document('/NTUTLab321/{machineId}')
  .onUpdate(async (change) => {
    const data = change.after.data() as Machine
    const machineId = change.after.id
    const machinePosition = data.judge ?? data.title
    
    // validate the data
    if (isEmptyObject(data) || !machinePosition) {
      logger.error('could not receive the new machine data pack!')
      return
    }
    
    // get the guest account that match to this machine.
    let guestDoc = await getGuest(machineId)
    if (isEmptyObject(guestDoc)) {
      logger.warn(`there is a machine(${machineId}) that not have a guest account! try to automatically create a new one...`)
      await createNewGuest(machinePosition, machineId)
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
        logger.error('could not update a guest document in guests collection.\n' + e)
      }
    }
  })

export const onDeleteMachine = functions.firestore.document('/NTUTLab321/{machineId}')
  .onDelete(async (snapshot) => {
    const data = snapshot.data() as Machine
    const machineId = snapshot.id
    
    // validate the data
    if (isEmptyObject(data)) {
      logger.error('could not receive the new machine data pack!')
      return
    }
    
    // check if this machine is still having a guest account.
    if (await isThisMachineRegisteredAGuestAccount(machineId)) {
      // delete the guest account's document.
      try {
        await admin.firestore()
          .collection('/guests')
          .doc(machineId)
          .delete()
      } catch (e) {
        logger.error('could not delete a guest document in guests collection.\n' + e)
      }
    } else {
      logger.info(`This machine(${machineId}) is already lost its guest account, delete operation done.`)
    }
  })
