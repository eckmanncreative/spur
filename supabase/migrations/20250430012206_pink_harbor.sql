/*
  # Create test users

  1. Changes
    - Insert 50 test users with unique usernames
    - Add diverse first and last names
    - Ensure username uniqueness
*/

-- Insert test users
INSERT INTO profiles (username, name, first_name, last_name) VALUES
  ('pixelPirate', 'Pixel Pirate', 'Zara', 'Chen'),
  ('cosmicCoder', 'Cosmic Coder', 'Aiden', 'Patel'),
  ('neonNinja', 'Neon Ninja', 'Luna', 'Kim'),
  ('quantumQuester', 'Quantum Quester', 'Xavier', 'Rodriguez'),
  ('byteBard', 'Byte Bard', 'Maya', 'Singh'),
  ('dataDruid', 'Data Druid', 'Kai', 'Tanaka'),
  ('cyberScribe', 'Cyber Scribe', 'Nova', 'Williams'),
  ('techTroubadour', 'Tech Troubadour', 'Atlas', 'Johnson'),
  ('digitalDragon', 'Digital Dragon', 'Aria', 'Zhang'),
  ('webWizard', 'Web Wizard', 'Leo', 'Martinez'),
  ('cloudCrafter', 'Cloud Crafter', 'Sage', 'Anderson'),
  ('syntaxSage', 'Syntax Sage', 'River', 'Thompson'),
  ('bitBreaker', 'Bit Breaker', 'Phoenix', 'Garcia'),
  ('codeCartographer', 'Code Cartographer', 'Sky', 'Brown'),
  ('algorithmArtist', 'Algorithm Artist', 'Eden', 'Lee'),
  ('debugDancer', 'Debug Dancer', 'Rain', 'Wilson'),
  ('gitGuardian', 'Git Guardian', 'Storm', 'Taylor'),
  ('stackSurfer', 'Stack Surfer', 'Ash', 'Moore'),
  ('kernelKnight', 'Kernel Knight', 'Raven', 'Jackson'),
  ('scriptScientist', 'Script Scientist', 'Dawn', 'White'),
  ('devDiplomat', 'Dev Diplomat', 'Echo', 'Davis'),
  ('hashHacker', 'Hash Hacker', 'Sol', 'Miller'),
  ('loopLegend', 'Loop Legend', 'Skye', 'Jones'),
  ('byteBlacksmith', 'Byte Blacksmith', 'Vale', 'Martin'),
  ('rootRanger', 'Root Ranger', 'Brook', 'Clark'),
  ('nullNomad', 'Null Nomad', 'Wren', 'Walker'),
  ('pingPioneer', 'Ping Pioneer', 'Sage', 'Wright'),
  ('cacheCowboy', 'Cache Cowboy', 'Bay', 'Lopez'),
  ('cryptoCrusader', 'Crypto Crusader', 'Lake', 'Hill'),
  ('bugBouncer', 'Bug Bouncer', 'Reed', 'Scott'),
  ('dataDetective', 'Data Detective', 'Fern', 'Green'),
  ('pixelProphet', 'Pixel Prophet', 'Elm', 'Adams'),
  ('queryQuester', 'Query Quester', 'Oak', 'Baker'),
  ('shellShaman', 'Shell Shaman', 'Pine', 'Evans'),
  ('bitBard', 'Bit Bard', 'Ash', 'Foster'),
  ('codeChef', 'Code Chef', 'Rowan', 'Morris'),
  ('webWarrior', 'Web Warrior', 'Blair', 'Powell'),
  ('stackSage', 'Stack Sage', 'Quinn', 'Butler'),
  ('devDruid', 'Dev Druid', 'Aspen', 'Barnes'),
  ('gitGuru', 'Git Guru', 'Robin', 'Fisher'),
  ('hashHunter', 'Hash Hunter', 'Sage', 'Coleman'),
  ('loopLancer', 'Loop Lancer', 'Dale', 'Jenkins'),
  ('byteBaron', 'Byte Baron', 'Winter', 'Perry'),
  ('rootRider', 'Root Rider', 'Summer', 'Powell'),
  ('nullNinja', 'Null Ninja', 'Autumn', 'Long'),
  ('pingPaladin', 'Ping Paladin', 'Spring', 'Patterson'),
  ('cacheCaptain', 'Cache Captain', 'North', 'Hughes'),
  ('cryptoKeeper', 'Crypto Keeper', 'West', 'Price'),
  ('bugBuster', 'Bug Buster', 'East', 'Ross'),
  ('dataDragon', 'Data Dragon', 'South', 'Bennett');