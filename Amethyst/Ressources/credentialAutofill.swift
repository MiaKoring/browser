//
//  credentialAutofill.swift
//  Amethyst Project
//
//  Created by Mia Koring on 11.04.25.
//

let credentialAutofillJS = """
function amethystAutofillCredentials(username, password) {
  const usernameSelectors = [
    'input[type="email"]',
    'input[name*="user"]',
    'input[id*="user"]',
    'input[name*="email"]',
    'input[id*="email"]',
    'input[name*="username"]',
    'input[id*="username"]',
    'input[autocomplete="username"]',
    'input[autocomplete="email"]',
  ];

  const passwordSelectors = [
    'input[type="password"]',
    'input[name*="pass"]',
    'input[id*="password"]',
    'input[autocomplete="current-password"]',
    'input[autocomplete="new-password"]',
  ];

  // Helper to simulate a "trusted-like" interaction
  const setValueAndTriggerEvents = (element, value) => {
    if (!element) return;

    // 1. Focus the element
    element.focus();

    // 2. Set the value
    const lastValue = element.value;
    element.value = value;

    // 3. Create and dispatch the 'input' event (crucial for React/Vue)
    const event = new Event("input", { bubbles: true });
    
    // Hack for some frameworks that check for property descriptors
    const tracker = element._valueTracker;
    if (tracker) {
      tracker.setValue(lastValue);
    }

    element.dispatchEvent(event);

    // 4. Dispatch 'change' and 'blur' to finalize validation
    element.dispatchEvent(new Event("change", { bubbles: true }));
    element.blur();
  };

  // Find and fill Username
  usernameSelectors.some((selector) => {
    const field = document.querySelector(selector);
    if (field && field.offsetParent !== null) { // Ensure element is visible
      setValueAndTriggerEvents(field, username);
      return true;
    }
    return false;
  });

  // Find and fill Password
  passwordSelectors.some((selector) => {
    const field = document.querySelector(selector);
    if (field && field.offsetParent !== null) {
      setValueAndTriggerEvents(field, password);
      return true;
    }
    return false;
  });
}
"""
