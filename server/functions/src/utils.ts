import {DecodedIdToken} from "./types";

const admin = require('firebase-admin');

export const isEmail = (experimentalEmail: string): boolean => {
  const emailRegExp = new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
  return emailRegExp.test(experimentalEmail)
}

export const decryptJwt = async (jwt: string): Promise<DecodedIdToken | undefined> => {
  try {
    return await admin.auth().verifyIdToken(jwt)
  } catch (e) {
    return undefined
  }
}

export const validatePermissionAndGetDocument = async (requesterUid: string, requiredPermissions: Array<string>): Promise<any | undefined> => {
  for (const requiredPermission of requiredPermissions) {
    try {
      const userDocument = (
        await admin.firestore()
          .collection('/' + requiredPermission + 's')
          .doc(requesterUid)
          .get()
      ).data()
      const permission = userDocument['role'].toString()
      if (permission && requiredPermission === permission) {
        return userDocument
      }
    } catch {
    }
  }
  return undefined
}

export const generateNewSha = (data: any): string => {
  const crypto = require('crypto')
  return crypto.createHash('sha3-512')
    .update(data.toString())
    .digest('hex')
}

export const getRandomSerial = (size: number): string => {
  const now = Date.now()
  const randomKeyA = Math.random()
  const randomKeyB = Math.random()
  return generateNewSha(now * randomKeyA * randomKeyB).slice(0, size > 128 ? 128 : size)
}

export const isEmptyObject = (object?: Object): boolean => {
  return !Boolean(object) || (Object.keys(object as Object).length === 0 && (object as Object).constructor === Object)
}

export const rootKey = '7e1cbfa86c1ef2c47081cadf7d36c70c89cae491a74a0dc6112964e2bf6958772082c390080681c8048f5e3f46bd56be8df980107c483c03594a24bbe06f49d6'
export const reGenerateSerialNumberDurationTime = 300 * 1000
