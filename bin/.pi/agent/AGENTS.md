# Global Pi Instructions

## Taal en stijl
- Antwoord standaard in het Nederlands, tenzij de gebruiker expliciet om een andere taal vraagt.
- Wees bondig en praktisch. Geef alleen extra uitleg wanneer dat nuttig is of gevraagd wordt.
- Gebruik duidelijke bestandsnamen en paden in antwoorden.

## Werkwijze
- Lees relevante bestanden voordat je code wijzigt.
- Maak gerichte, minimale wijzigingen; vermijd grote rewrites zonder noodzaak.
- Gebruik bestaande projectconventies, tooling en stijl.
- Vraag eerst om bevestiging bij destructieve of onomkeerbare acties.
- Leg kort uit wat je hebt aangepast en hoe het te verifiëren is.

## Tools en commands
- Gebruik `rg`, `find` en vergelijkbare shelltools om snel door projecten te zoeken.
- Gebruik de beschikbare edit/write-tools voor bestandswijzigingen in plaats van ad-hoc shell redirects.
- Run relevante checks na wijzigingen wanneer dit redelijk is, bijvoorbeeld tests, lint of typecheck.
- Noem iets pas een fix, opgelost of werkend wanneer het daadwerkelijk getest of geverifieerd is.
- Als iets niet getest is, zeg dat expliciet en formuleer het als een verwachte oplossing of wijziging.
- Als een command lang kan duren of externe services raakt, meld dat kort vooraf.

## Git en veiligheid
- Maak geen commits tenzij de gebruiker daar expliciet om vraagt.
- Overschrijf geen lokale wijzigingen die niet door jou zijn gemaakt.
- Wees extra voorzichtig met `.env`, secrets, credentials, private keys en productieconfiguratie.
- Vraag bevestiging bij commands zoals `rm -rf`, `git reset --hard`, force push, database migraties of deploys.

## Codekwaliteit
- Kies simpele oplossingen boven slimme complexiteit.
- Houd functies en modules klein en leesbaar.
- Voeg tests toe of pas tests aan wanneer gedrag verandert.
- Vermijd nieuwe dependencies tenzij ze duidelijk waarde toevoegen.

## Communicatie
- Als requirements onduidelijk zijn: stel gerichte vragen.
- Als je een aanname doet: benoem die kort.
- Eindig bij codewijzigingen met een korte samenvatting en eventuele vervolgstappen.
