# Pokémon Legends: Z-A support — data snapshot 1 October 2026

LibreDex bundles a curated reference overlay of **49 Mega form records** (PokéAPI form IDs `10278–10326`), including forms introduced with Pokémon Legends: Z-A and its Mega Dimension DLC, released **10 December 2025**. This overlay is form and battle metadata—not a complete story guide, DLC walkthrough, or claim that every form is usable in Pokémon Champions.

## 🌀 Mega Dimension DLC coverage

The overlay represents **23 local form records** from Mega Dimension (`10304–10326`) across 18 base species. These are data IDs, not a claim that there are 23 distinct Mega Evolutions: the local rows keep Raichu X/Y, both Meowstic sex records, both Magearna appearances, and all three Tatsugiri appearances separate. Other references use different counting conventions, so use the bundled ID list for LibreDex record counts:

- Mega Raichu X and Mega Raichu Y
- Mega Chimecho
- Mega Baxcalibur
- Mega Zeraora
- Mega Absol Z
- Mega Garchomp Z
- Mega Lucario Z
- Mega Heatran
- Mega Darkrai
- Mega Golurk
- Mega Golisopod
- Mega Glimmora
- Mega Scovillain
- Mega Staraptor
- Mega Meowstic (Male and Female)
- Mega Crabominable
- Mega Magearna and Mega Magearna (Original Color)
- Mega Tatsugiri (Curly, Droopy, and Stretchy)

The 26 base-game Legends: Z-A Mega form records use IDs `10278–10303`: **Clefable, Victreebel, Starmie, Dragonite, Meganium, Feraligatr, Skarmory, Froslass, Emboar, Excadrill, Scolipede, Scrafty, Eelektross, Chandelure, Chesnaught, Delphox, Greninja, Pyroar, Eternal Flower Floette, Malamar, Barbaracle, Dragalge, Hawlucha, Zygarde, Drampa,** and **Falinks**.

## 🏷️ Form flags, origin, and regulation eligibility

- Each overlay Mega form has the `mega` and `legendsZA` flags. `champions` is used only where curated Pokémon Champions ability data is available; it does **not** mean the form is eligible in every Champions regulation.
- Regulation M-C membership comes only from [`assets/data/champions_regulation_mc.json`](../assets/data/champions_regulation_mc.json). Do not turn a `Legends: Z-A` origin tag into Champions eligibility or infer either fact from the numeric ID.
- Mega Stone item rows are retained and enriched in place. Provenance is explicit per record. For example, the official [Z-A Battle Club ranked-battle rewards](https://legends.pokemon.com/en-gb/news/battle-club-ranked-battles) include **Baxcalibrite**; its origin is Legends: Z-A even though the item is also eligible in the M-C catalog.
- PokéAPI form IDs and sprite URLs provide stable data keys/asset links. Display names, source flags, notes, special ability assignments, and known bad artwork exceptions remain reviewed local metadata.

## ⚔️ Effort Levels and NatureDex

Legends: Z-A uses Effort Levels rather than the mainline EV-growth model. LibreDex explains that distinction in NatureDex while keeping the `+10% / −10%` modifier display for side-by-side comparison with Champions/mainline. Do not use the comparison display as a claim that the games share an identical stat-building system.

## 🔎 Search aliases — Pokédex and MoveDex

Supported searches include `Legends ZA`, `Legends Z-A`, `LegendsZ-A`, `LegendsZA`, `Mega`, `New Mega`, `Mega Raichu X`, `Mega Raichu Y`, `Eternal Flower Floette`, `Floette Eternal`, `Hyperspace`, `Hoopa`, `Ansha`, and ability names on overlay forms such as `Magic Bounce` or `Dragonize`. The catalog token search is order-free for multiword form/ability names.

## 🧾 Source notes and verification limits

- PokéAPI's v2 CSV tables supply standard IDs, statistics, typings, and any upstream ability records used by the form builder. The local builder's reviewed `CURATED_FORMS` table supplies names, form labels, flags, and source notes that PokéAPI does not publish.
- The [official Mega Dimension launch page](https://legends.pokemon.com/en-us/news/mega-dimension-launch) and [official trailer announcement](https://legends.pokemon.com/en-us/news/december-09-mega-dimension-trailer) establish DLC release and examples of its new Mega forms. Individual official news pages, such as the [Mega Zeraora announcement](https://legends.pokemon.com/en-us/news/mega_zeraora), corroborate specific additions.
- The [official Z-A Battle Club reward page](https://legends.pokemon.com/en-gb/news/battle-club-ranked-battles) is the provenance source for Baxcalibrite as a ranked reward.
- The complete 49-record mapping is curated from the checked-in form table and cross-checked against PokéAPI and Serebii's [Legends: Z-A Mega list](https://www.serebii.net/legendsz-a/megaevolutions.shtml) and [Mega Dimension list](https://www.serebii.net/legendsz-a/dlc-megaevolutions.shtml); no single official page enumerates every bundled record. Community references also use different count conventions (for example, [Bulbapedia's Mega Dimension entry](https://bulbapedia.bulbagarden.net/wiki/Mega_Dimension) counts species, Mega identities, and alternate forms separately). The local `forms_extra.json` and its metadata are the app's exact snapshot.
- Sprite URLs can change upstream. `tools/fix_sprite_urls.py` records known invalid/missing HOME renders and the fallback behavior. The Eternal Flower Floette shiny URL is intentionally blank because that form cannot officially be shiny and the upstream render is broken.

See [Data pipeline and provenance](data-pipeline.md) for the regeneration process and the source-revision caveat.
