// zero or more alpha groups ending in hyphen, followed by a group of only alphas, the end
export const tas = /^(?:[A-Za-z]+-)*(?:[A-Za-z]+)$/;
// for input pattern fields
export const tasPattern = "^(?:[A-Za-z]+-)*(?:[A-Za-z]+)$";

export const path = /^(?:\/[\w\d-]*)(?:\/[\w\d-]+)*$/;
export const pathPattern = "^(?:\\/[\\w\\d-]*)(?:\\/[\\w\\d-]+)*$";

export const sgApiKey = /^SG\.(?:[a-zA-Z0-9\\._-]{66})$/;
export const sgApiKeyPattern = "^SG\\.(?:[a-zA-Z0-9\\._-]{66})$";

export const email = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
// The 'pattern' values are meant to be used in the [pattern] attribute of an
// <input>. Typically you'd use an <input type="email"> to validate an email
// address, so this probably isn't necessary.
// export const emailPattern = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
