//
//  credentialAutofill.swift
//  Amethyst Project
//
//  Created by Mia Koring on 11.04.25.
//

let credentialAutofillJS = """
function amethystAutofillCredentials(username, password) {
  // Selektoren für mögliche Benutzername-Felder
  const usernameSelectors = [
    'input[type="email"]',
    'input[name*="user"]',
    'input[id*="user"]',
    'input[name*="email"]',
    'input[id*="email"]',
    'input[name*="username"]',
    'input[id*="username"]',
  ];

  // Selektoren für mögliche Passwort-Felder
  const passwordSelectors = [
    'input[type="password"]',
    'input[name*="pass"]',
    'input[id*="pass"]'
  ];

  let usernameFieldFound = false;
  let passwordFieldFound = false;

  // Suche nach einem passenden Feld für den Benutzernamen
  usernameSelectors.some(selector => {
    const field = document.querySelector(selector);
    if (field) {
      field.value = username;
      usernameFieldFound = true;
      return true; // Beende die Schleife, sobald ein Feld gefunden wurde
    }
    return false;
  });

  // Suche nach einem passenden Passwort-Feld
  passwordSelectors.some(selector => {
    const field = document.querySelector(selector);
    if (field) {
      field.value = password;
      passwordFieldFound = true;
      return true; // Beende die Schleife, sobald ein Feld gefunden wurde
    }
    return false;
  });
}
"""
