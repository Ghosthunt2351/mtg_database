-- Цель создания базы данных: Создать базу карт для колекционной карточной игры Magic: The Gathering, с помощью которой будет просто находить необходимые
-- карты по различным критериям, по аналогии с поиском на сайтах электронных магазинов (например: https://starcitygames.com/search/advanced).
-- Базу можно дополнить количеством карт в собственной коллекции или ссылками на цены в популярных магазинах. 

DROP DATABASE IF EXISTS `mtg_cards`;
CREATE DATABASE `mtg_cards`;
USE `mtg_cards`;

-- --------------------------------------- Создание таблиц (DDL) ----------------------------------------------

DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages` (
	`id` SERIAL PRIMARY KEY,
	`name` CHAR(20) NOT NULL UNIQUE,
	`short_name` CHAR(10) NOT NULL UNIQUE
) COMMENT = 'Язык перевода';

DROP TABLE IF EXISTS `sets`;
CREATE TABLE `sets` (
	`id` SERIAL PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL COMMENT 'Название издания',
	`short name` CHAR(10) NOT NULL COMMENT 'Сокращение',
	`quantity` INT NOT NULL COMMENT 'Количество карт в издании',
	`date` DATE NOT NULL COMMENT 'Дата выпуска',
	`type` ENUM('Basic', 'Promo', 'Special') DEFAULT 'Basic' COMMENT 'Тип выпуска',
	`language_id` BIGINT UNSIGNED NOT NULL COMMENT 'Язык издания',
	
	FOREIGN KEY (`language_id`) REFERENCES `languages`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Издания';

DROP TABLE IF EXISTS `types`;
CREATE TABLE `types` (
	`id` SERIAL PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL COMMENT 'Название типа'
) COMMENT = 'Типы карт';

DROP TABLE IF EXISTS `types_string`;
CREATE TABLE `types_string` (
	`id` SERIAL PRIMARY KEY,
	`type_id_1` BIGINT UNSIGNED NOT NULL,
	`type_id_2` BIGINT UNSIGNED,
	`type_id_3` BIGINT UNSIGNED,
	`type_id_4` BIGINT UNSIGNED,
	FOREIGN KEY (`type_id_1`) REFERENCES `types`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (`type_id_2`) REFERENCES `types`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (`type_id_3`) REFERENCES `types`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (`type_id_4`) REFERENCES `types`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Строка типов карты'; -- Может быть до 4х типов на одной карте в разных сочетаниях

DROP TABLE IF EXISTS `rarities`;
CREATE TABLE `rarities` (
	`id` SERIAL PRIMARY KEY,
	`name` CHAR(20) NOT NULL UNIQUE,
	`short_name` CHAR(1) NOT NULL UNIQUE 
) COMMENT = 'Редкость карты';

DROP TABLE IF EXISTS `colors`;
CREATE TABLE `colors` (
	`id` SERIAL PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL UNIQUE,
	`short_name` CHAR(1) NOT NULL UNIQUE 
) COMMENT = 'Цвет карты';

DROP TABLE IF EXISTS `cards`;
CREATE TABLE `cards` (
	`id` SERIAL PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL COMMENT 'Название карты',
	`number` BIGINT UNSIGNED NOT NULL COMMENT 'Номер карты в издании',
	`set_id` BIGINT UNSIGNED NOT NULL COMMENT 'Издание',
	`type_string_id` BIGINT UNSIGNED NOT NULL COMMENT 'Тип карты',
	`rarity_id` BIGINT UNSIGNED NOT NULL COMMENT 'Редкость',
	`mana_cost` CHAR(10) NOT NULL COMMENT 'Мана-стоимость карты', 
	`mana_value` INT NOT NULL COMMENT 'Мановая ценность',
	`artist` VARCHAR(100) NOT NULL COMMENT 'Художник',
	`body` TEXT COMMENT 'Способности, эффекты',
	`color_id` BIGINT UNSIGNED NOT NULL COMMENT 'Цвет карты',
	`power_toughness_loyality` CHAR(10) DEFAULT NULL COMMENT 'Значение силы/выносливости существ или лояльности плейнсволкеров',
	`flavor_text` VARCHAR(255) DEFAULT NULL COMMENT 'Художественный текст',
	FOREIGN KEY (`set_id`) REFERENCES `sets`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (`type_string_id`) REFERENCES `types_string`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (`rarity_id`) REFERENCES `rarities`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (`color_id`) REFERENCES `colors`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Карты'; -- основная таблица

DROP TABLE IF EXISTS `format_legal`;
CREATE TABLE `format_legal` (
	`card_id` SERIAL PRIMARY KEY,
	`standard` ENUM('Legal', 'Not legal', 'Banned', 'Restricted'),
	`modern` ENUM('Legal', 'Not legal', 'Banned', 'Restricted'),
	`legacy` ENUM('Legal', 'Not legal', 'Banned', 'Restricted'),
	`vintage` ENUM('Legal', 'Not legal', 'Banned', 'Restricted'),
	`commander` ENUM('Legal', 'Not legal', 'Banned', 'Restricted'),
	`pauper` ENUM('Legal', 'Not legal', 'Banned', 'Restricted'),
	FOREIGN KEY (`card_id`) REFERENCES `cards`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Легальность в турнирных форматах';

DROP TABLE IF EXISTS `key_abilities`;
CREATE TABLE `key_abilities`(
	`id` SERIAL PRIMARY KEY,
	`name` VARCHAR(50) UNIQUE NOT NULL COMMENT 'Наименование способности',
	`discrtiption` TEXT COMMENT 'Описание способности'
) COMMENT = 'Ключевые способности';

DROP TABLE IF EXISTS `card_abilities`;
CREATE TABLE `card_abilities`(
	`card_id` BIGINT UNSIGNED NOT NULL,
	`key_ability_id` BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (`card_id`, `key_ability_id`),
	FOREIGN KEY (`card_id`) REFERENCES `cards`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (`key_ability_id`) REFERENCES `key_abilities`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Ключевые способности карты';

-- ---------------------------------------------- Наполнение таблиц -------------------------------------------------------

INSERT INTO `languages` (`name`, `short_name`) VALUES ('English', 'EN'), ('Spanish', 'ES'), ('French', 'FR'), ('German', 'DE'), ('Italian', 'IT'), ('Portuguese', 'PT'), ('Japanese', 'JA'), ('Rorean', 'KO'), ('Russian', 'RU'), ('Chinese', 'CH');

INSERT INTO `sets` VALUES 
	(NULL, 'Dominaria United', 'DMU', 281, '2022-09-09', 'Basic', 1), 
	(NULL, 'Dominaria Unida', 'DMU', 281, '2022-09-09', 'Basic', 2),
	(NULL, 'Dominaria Uni', 'DMU', 281, '2022-09-09', 'Basic', 3),
	(NULL, 'Dominarias Bund', 'DMU', 281, '2022-09-09', 'Basic', 4),
	(NULL, 'Dominaria Unita', 'DMU', 281, '2022-09-09', 'Basic', 5),
	(NULL, 'Dominaria Unida', 'DMU', 281, '2022-09-09', 'Basic', 6),
	(NULL, 'Double Masters', '2X2', 332, '2022-08-07', 'Special', 1),
	(NULL, 'Double Masters', '2X2', 332, '2022-08-07', 'Special', 3),
	(NULL, 'Double Masters', '2X2', 332, '2022-08-07', 'Special', 4),
	(NULL, 'Streets of New Capenna', 'SNC', 278, '2022-04-29', 'Basic', 1),
	(NULL, 'Calles de Nueva Capenna', 'SNC', 278, '2022-04-29', 'Basic', 2),
	(NULL, 'Les Rues de la Nouvelle-Capenna', 'SNC', 278, '2022-04-29', 'Basic', 3),
	(NULL, 'Strassen von Neu-Capenna', 'SNC', 278, '2022-04-29', 'Basic', 4),
	(NULL, 'Strade di Nuova Capenna', 'SNC', 278, '2022-04-29', 'Basic', 5),
	(NULL, 'Ruas de Nova Capenna', 'SNC', 278, '2022-04-29', 'Basic', 6),
	(NULL, 'Улицы Новой Капенны', 'SNC', 278, '2022-04-29', 'Basic', 9);

INSERT INTO `types` (`name`) VALUES ("Basic"), ("Legendary"), ("Ongoing"), ("Snow"), ("World"), ("Artifact"), ("Attraction"), ("Blood"), ("Clue"), ("Contraption"), ("Equipment"), ("Food"), ("Fortification"), ("Gold"), ("Treasure"), ("Vehicle"), ("Conspiracy"), ("Enchantment"), ("Aura"), ("Background"), ("Cartouche"), ("Class"), ("Curse"), ("Rune"), ("Saga"), ("Shard"), ("Shrine"), ("Instant"), ("Sorcery"), ("Adventure"), ("Arcane"), ("Lesson"), ("Trap"), ("Land"), ("Desert"), ("Forest"), ("Gate"), ("Island"), ("Lair"), ("Locus"), ("Mine"), ("Mountain"), ("Plains"), ("Power-Plant"), ("Swamp"), ("Tower"), ("Urza’s"), ("Creature"), ("Advisor"), ("Aetherborn"), ("Alien"), ("Ally"), ("Angel"), ("Antelope"), ("Ape"), ("Archer"), ("Archon"), ("Army"), ("Artificer"), ("Assassin"), ("Assembly-Worker"), ("Astartes"), ("Atog"), ("Aurochs"), ("Avatar"), ("Azra"), ("Badger"), ("Balloon"), ("Barbarian"), ("Bard"), ("Basilisk"), ("Bat"), ("Bear"), ("Beast"), ("Beeble"), ("Beholder"), ("Berserker"), ("Bird"), ("Blinkmoth"), ("Boar"), ("Bringer"), ("Brushwagg"), ("C'tan"), ("Camarid"), ("Camel"), ("Caribou"), ("Carrier"), ("Cat"), ("Centaur"), ("Cephalid"), ("Chicken"), ("Child"), ("Chimera"), ("Citizen"), ("Cleric"), ("Clown"), ("Cockatrice"), ("Construct"), ("Coward"), ("Crab"), ("Crocodile"), ("Custodes"), ("Cyclops"), ("Dauthi"), ("Demigod"), ("Demon"), ("Deserter"), ("Devil"), ("Dinosaur"), ("Djinn"), ("Dog"), ("Dragon"), ("Drake"), ("Dreadnought"), ("Drone"), ("Druid"), ("Dryad"), ("Dwarf"), ("Efreet"), ("Egg"), ("Elder"), ("Eldrazi"), ("Elemental"), ("Elephant"), ("Elf"), ("Elk"), ("Employee"), ("Eye"), ("Faerie"), ("Ferret"), ("Fish"), ("Flagbearer"), ("Fox"), ("Fractal"), ("Frog"), ("Fungus"), ("Gamer"), ("Gargoyle"), ("Germ"), ("Giant"), ("Gith"), ("Gnoll"), ("Gnome"), ("Goat"), ("Goblin"), ("God"), ("Golem"), ("Gorgon"), ("Graveborn"), ("Gremlin"), ("Griffin"), ("Guest"), ("Hag"), ("Halfling"), ("Hamster"), ("Harpy"), ("Head"), ("Hellion"), ("Hippo"), ("Hippogriff"), ("Homarid"), ("Homunculus"), ("Hornet"), ("Horror"), ("Horse"), ("Human"), ("Hydra"), ("Hyena"), ("Illusion"), ("Imp"), ("Incarnation"), ("Inkling"), ("Inquisitor"), ("Insect"), ("Jackal"), ("Jellyfish"), ("Juggernaut"), ("Kavu"), ("Kirin"), ("Kithkin"), ("Knight"), ("Kobold"), ("Kor"), ("Kraken"), ("Lamia"), ("Lammasu"), ("Leech"), ("Leviathan"), ("Lhurgoyf"), ("Licid"), ("Lizard"), ("Manticore"), ("Masticore"), ("Mercenary"), ("Merfolk"), ("Metathran"), ("Minion"), ("Minotaur"), ("Mole"), ("Monger"), ("Mongoose"), ("Monk"), ("Monkey"), ("Moonfolk"), ("Mouse"), ("Mutant"), ("Myr"), ("Mystic"), ("Naga"), ("Nautilus"), ("Necron"), ("Nephilim"), ("Nightmare"), ("Nightstalker"), ("Ninja"), ("Noble"), ("Noggle"), ("Nomad"), ("Nymph"), ("Octopus"), ("Ogre"), ("Ooze"), ("Orb"), ("Orc"), ("Orgg"), ("Otter"), ("Ouphe"), ("Ox"), ("Oyster"), ("Pangolin"), ("Peasant"), ("Pegasus"), ("Pentavite"), ("Performer"), ("Pest"), ("Phelddagrif"), ("Phoenix"), ("Phyrexian"), ("Pilot"), ("Pincher"), ("Pirate"), ("Plant"), ("Praetor"), ("Primarch"), ("Prism"), ("Processor"), ("Rabbit"), ("Raccoon"), ("Ranger"), ("Rat"), ("Rebel"), ("Reflection"), ("Reveler"), ("Rhino"), ("Rigger"), ("Robot"), ("Rogue"), ("Sable"), ("Salamander"), ("Samurai"), ("Sand"), ("Saproling"), ("Satyr"), ("Scarecrow"), ("Scion"), ("Scorpion"), ("Scout"), ("Sculpture"), ("Serf"), ("Serpent"), ("Servo"), ("Shade"), ("Shaman"), ("Shapeshifter"), ("Shark"), ("Sheep"), ("Siren"), ("Skeleton"), ("Slith"), ("Sliver"), ("Slug"), ("Snake"), ("Soldier"), ("Soltari"), ("Spawn"), ("Specter"), ("Spellshaper"), ("Sphinx"), ("Spider"), ("Spike"), ("Spirit"), ("Splinter"), ("Sponge"), ("Squid"), ("Squirrel"), ("Starfish"), ("Surrakar"), ("Survivor"), ("Teddy"), ("Tentacle"), ("Tetravite"), ("Thalakos"), ("Thopter"), ("Thrull"), ("Tiefling"), ("Treefolk"), ("Trilobite"), ("Triskelavite"), ("Troll"), ("Turtle"), ("Tyranid"), ("Unicorn"), ("Vampire"), ("Vedalken"), ("Viashino"), ("Volver"), ("Wall"), ("Walrus"), ("Warlock"), ("Warrior"), ("Wasp"), ("Weird"), ("Werewolf"), ("Whale"), ("Wizard"), ("Wolf"), ("Wolverine"), ("Wombat"), ("Worm"), ("Wraith"), ("Wurm"), ("Yeti"), ("Zombie"), ("Zubera"), ("Phenomenon"), ("Plane"), ("Alara"), ("Arkhos"), ("Azgol"), ("Belenon"), ("Bolas’s Meditation Realm"), ("Dominaria"), ("Equilor"), ("Ergamon"), ("Fabacin"), ("Innistrad"), ("Iquatana"), ("Ir"), ("Kaldheim"), ("Kamigawa"), ("Karsus"), ("Kephalai"), ("Kinshala"), ("Kolbahan"), ("Kyneth"), ("Lorwyn"), ("Luvion"), ("Mercadia"), ("Mirrodin"), ("Moag"), ("Mongseng"), ("Muraganda"), ("New Phyrexia"), ("Phyrexia"), ("Pyrulea"), ("Rabiah"), ("Rath"), ("Ravnica"), ("Regatha"), ("Segovia"), ("Serra’s Realm"), ("Shadowmoor"), ("Shandalar"), ("Ulgrotha"), ("Valla"), ("Vryn"), ("Wildfire"), ("Xerex"), ("Zendikar"), ("Planeswalker"), ("Abian"), ("Ajani"), ("Aminatou"), ("Angrath"), ("Arlinn"), ("Ashiok"), ("B.O.B."), ("Bahamut"), ("Basri"), ("Bolas"), ("Calix"), ("Chandra"), ("Comet"), ("Dack"), ("Dakkon"), ("Daretti"), ("Davriel"), ("Dihada"), ("Domri"), ("Dovin"), ("Duck"), ("Dungeon"), ("Ellywick"), ("Elminster"), ("Elspeth"), ("Estrid"), ("Freyalise"), ("Garruk"), ("Gideon"), ("Grist"), ("Huatli"), ("Inzerva"), ("Jace"), ("Jared"), ("Jaya"), ("Jeska"), ("Kaito"), ("Karn"), ("Kasmina"), ("Kaya"), ("Kiora"), ("Koth"), ("Liliana"), ("Lolth"), ("Lukka"), ("Master"), ("Minsc"), ("Mordenkainen"), ("Nahiri"), ("Narset"), ("Niko"), ("Nissa"), ("Nixilis"), ("Oko"), ("Ral"), ("Rowan"), ("Saheeli"), ("Samut"), ("Sarkhan"), ("Serra"), ("Sivitri"), ("Sorin"), ("Szat"), ("Tamiyo"), ("Tasha"), ("Teferi"), ("Teyo"), ("Tezzeret"), ("Tibalt"), ("Tyvar"), ("Ugin"), ("Urza"), ("Venser"), ("Vivien"), ("Vraska"), ("Will"), ("Windgrace"), ("Wrenn"), ("Xenagos"), ("Yanggu"), ("Yanling"), ("Zariel"), ("Scheme"), ("Vanguard");

-- SELECT * FROM `types` WHERE name IN ('creature', 'human', 'warrior'); -- для быстрого подбора id типов карт

INSERT INTO `types_string` VALUES 
	(NULL, 2, 380, 418, NULL),
	(NULL, 48, 166, 95, NULL),
	(NULL, 48, 53, NULL, NULL),
	(NULL, 28, NULL, NULL, NULL),
	(NULL, 29, NULL, NULL, NULL),
	(NULL, 18, NULL, NULL, NULL),
	(NULL, 18, 25, NULL, NULL),
	(NULL, 2, 380, 423, NULL),
	(NULL, 2, 48, 166, 320);

INSERT INTO `rarities` (`name`, `short_name`) VALUES ('Common', 'C'), ('Uncommon', 'U'), ('Rare', 'R'), ('Mythic Rare', 'M');

INSERT INTO `colors` (`name`, `short_name`) VALUES ('White', 'W'), ('Blue', 'U'), ('Green', 'G'), ('Red', 'R'), ('Black', 'B'), ('Multicolored', 'M'), ('Colorless', 'C');

INSERT INTO `cards` VALUES
	(NULL, 'Karn, Living Legacy', 001, 1, 1, 4, '4', 4, 'Chris Rahn', '+1: Create a tapped Powerstone token. (It’s an artifact with “{T}: Add {C}. This mana can’t be spent to cast a nonartifact spell.”) −1: Pay any amount of mana. Look at that many cards from the top of your library, then put one of those cards into your hand and the rest on the bottom of your library in a random order. −7: You get an emblem with “Tap an untapped artifact you control: This emblem deals 1 damage to any target.”', 7, '4', NULL),
	(NULL, 'Anointed Peacekeeper', 002, 1, 2, 3, '2{W}', 3, 'Tia Masic', 'Vigilance. As Anointed Peacekeeper enters the battlefield, look at an opponent’s hand, then choose any card name. Spells your opponents cast with the chosen name cost {2} more to cast. Activated abilities of sources with the chosen name cost {2} more to activate unless they’re mana abilities.', 1, '3/3', NULL),
	(NULL, 'Archangel of Wrath', 003, 1, 3, 3, '2{W}{W}', 4, 'Miguel Mercado', 'Kicker {B} and/or {R} (You may pay an additional {B} and/or {R} as you cast this spell.) Flying, lifelink. When Archangel of Wrath enters the battlefield, if it was kicked, it deals 2 damage to any target. When Archangel of Wrath enters the battlefield, if it was kicked twice, it deals 2 damage to any target.', 1, '3/4', NULL),
	(NULL, 'Artillery Blast', 006, 1, 4, 2, '1{W}', 2, 'Julian Kok Joon Wen', 'Domain — Artillery Blast deals X damage to target tapped creature, where X is 1 plus the number of basic land types among lands you control.', 1, NULL, 'To conserve ammunition, Jhoira modified ancient Thran artillery cannons to fire gouts of pure Shivan lava.'),
	(NULL, "Captain's Call", 009, 1, 5, 1, '3{W}', 4, 'A. M. Sartor', 'Create three 1/1 white Soldier creature tokens.', 1, NULL, '“Argivia’s walls may run on powerstones, but its real power comes from its people.” —King Darien XLVII'),
	(NULL, "Citizen's Arrest", 011, 1, 6, 1, '1{W}{W}', 3, 'Wisnu Tan', 'When Citizen’s Arrest enters the battlefield, exile target creature or planeswalker an opponent controls until Citizen’s Arrest leaves the battlefield.', 1, NULL, '“What lurks behind the faces of those you think you can trust?”'),
	(NULL, 'Founding the Third Path', 050, 1, 7, 2, '1{U}', 2, 'Chris Seaman', 'Read ahead (Choose a chapter and start with that many lore counters. Add one after your draw step. Skipped chapters don’t trigger. Sacrifice after III.) I — You may cast an instant or sorcery spell with mana value 1 or 2 from your hand without paying its mana cost. II — Target player mills four cards. III — Exile target instant or sorcery card from your graveyard. Copy it. You may cast the copy.', 2, NULL, NULL),
	(NULL, 'Liliana of the Veil', 097, 1, 8, 4, '1{B}{B}', 3, 'Martina Fackova', '+1: Each player discards a card. −2: Target player sacrifices a creature. −6: Separate all permanents target player controls into two piles. That player sacrifices all permanents in the pile of their choice.', 5, '3', NULL),
	(NULL, 'Chaotic Transformation', 117, 1, 5, 3, '5{R}', 6, 'Joseph Meehan', 'Exile up to one target artifact, up to one target creature, up to one target enchantment, up to one target planeswalker, and/or up to one target land. For each permanent exiled this way, its controller reveals cards from the top of their library until they reveal a card that shares a card type with it, puts that card onto the battlefield, then shuffles.', 4, NULL, NULL),
	(NULL, 'Astor, Bearer of Blades', 194, 1, 9, 3, '2{R}{W}', 4, 'Josh Hass', 'When Astor, Bearer of Blades enters the battlefield, look at the top seven cards of your library. You may reveal an Equipment or Vehicle card from among them and put it into your hand. Put the rest on the bottom of your library in a random order. Equipment you control have equip {1}. Vehicles you control have crew 1.', 6, '4/4', NULL);

INSERT INTO `format_legal` VALUES 
	(1, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal'),
	(2, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal'),
	(3, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal'),
	(4, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal'),
	(5, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Legal'),
	(6, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Legal'),
	(7, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal'),
	(8, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal'),
	(9, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal'),
	(10, 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal');

INSERT INTO `key_abilities` (name) VALUES ("Battalion"), ("Bloodrush"), ("Channel"), ("Chroma"), ("Cohort"), ("Constellation"), ("Converge"), ("Delirium"), ("Domain"), ("Fateful hour"), ("Ferocious"), ("Formidable"), ("Grandeur"), ("Hellbent"), ("Heroic"), ("Imprint"), ("Inspired"), ("Join forces"), ("Kinship"), ("Landfall"), ("Lieutenant"), ("Metalcraft"), ("Morbid"), ("Parley"), ("Radiance"), ("Raid"), ("Rally"), ("Spell mastery"), ("Strive"), ("Sweep"), ("Tempting offer"), ("Threshold"), ("Will of the council"), ("Adamant"), ("Addendum"), ("Council's dilemma"), ("Eminence"), ("Enrage"), ("Hero's Reward"), ("Kinfall"), ("Landship"), ("Legacy"), ("Revolt"), ("Underdog"), ("Undergrowth"), ("Magecraft"), ("Teamwork"), ("Pack tactics"), ("Coven"), ("Alliance"), ("Living weapon"), ("Jump-start"), ("Basic landcycling"), ("Commander ninjutsu"), ("Legendary landwalk"), ("Nonbasic landwalk"), ("Totem armor"), ("Megamorph"), ("Haunt"), ("Forecast"), ("Graft"), ("Fortify"), ("Frenzy"), ("Gravestorm"), ("Hideaway"), ("Level Up"), ("Infect"), ("Reach"), ("Rampage"), ("Phasing"), ("Multikicker"), ("Morph"), ("Provoke"), ("Modular"), ("Ninjutsu"), ("Replicate"), ("Recover"), ("Poisonous"), ("Prowl"), ("Reinforce"), ("Persist"), ("Retrace"), ("Rebound"), ("Miracle"), ("Overload"), ("Outlast"), ("Prowess"), ("Renown"), ("Myriad"), ("Shroud"), ("Trample"), ("Vigilance"), ("Shadow"), ("Storm"), ("Soulshift"), ("Splice"), ("Transmute"), ("Ripple"), ("Suspend"), ("Vanishing"), ("Transfigure"), ("Wither"), ("Undying"), ("Soulbond"), ("Unleash"), ("Ascend"), ("Assist"), ("Afterlife"), ("Companion"), ("Fabricate"), ("Embalm"), ("Escape"), ("Fuse"), ("Menace"), ("Ingest"), ("Melee"), ("Improvise"), ("Mentor"), ("Partner"), ("Mutate"), ("Scavenge"), ("Tribute"), ("Surge"), ("Skulk"), ("Undaunted"), ("Riot"), ("Spectacle"), ("Forestwalk"), ("Islandwalk"), ("Mountainwalk"), ("Double strike"), ("Cumulative upkeep"), ("First strike"), ("Encore"), ("Sunburst"), ("Deathtouch"), ("Defender"), ("Foretell"), ("Amplify"), ("Affinity"), ("Bushido"), ("Convoke"), ("Bloodthirst"), ("Absorb"), ("Aura Swap"), ("Changeling"), ("Conspire"), ("Cascade"), ("Annihilator"), ("Battle Cry"), ("Cipher"), ("Bestow"), ("Dash"), ("Awaken"), ("Crew"), ("Aftermath"), ("Afflict"), ("Flanking"), ("Echo"), ("Fading"), ("Fear"), ("Eternalize"), ("Entwine"), ("Epic"), ("Dredge"), ("Delve"), ("Evoke"), ("Exalted"), ("Evolve"), ("Extort"), ("Dethrone"), ("Exploit"), ("Devoid"), ("Emerge"), ("Escalate"), ("Flying"), ("Haste"), ("Hexproof"), ("Indestructible"), ("Intimidate"), ("Lifelink"), ("Horsemanship"), ("Kicker"), ("Madness"), ("Hidden agenda"), ("Swampwalk"), ("Desertwalk"), ("Wizardcycling"), ("Slivercycling"), ("Cycling"), ("Landwalk"), ("Plainswalk"), ("Champion"), ("Enchant"), ("Plainscycling"), ("Islandcycling"), ("Swampcycling"), ("Mountaincycling"), ("Forestcycling"), ("Landcycling"), ("Typecycling"), ("Split second"), ("Flash"), ("Banding"), ("Augment"), ("Double agenda"), ("Partner with"), ("Hexproof from"), ("Boast"), ("Buyback"), ("Ward"), ("Demonstrate"), ("Devour"), ("Flashback"), ("Equip"), ("Reconfigure"), ("Compleated"), ("Daybound"), ("Nightbound"), ("Decayed"), ("Disturb"), ("Training"), ("Cleave"), ("Intensity"), ("Blitz"), ("Casualty"), ("Friends forever"), ("Protection"), ("Offering"), ("Enlist"), ("Read Ahead"), ("Squad"), ("Ravenous"), ("More Than Meets the Eye"), ("Living metal"), ("Unearth"), ("Meld"), ("Bolster"), ("Clash"), ("Fateseal"), ("Manifest"), ("Monstrosity"), ("Populate"), ("Proliferate"), ("Scry"), ("Support"), ("Detain"), ("Explore"), ("Fight"), ("Amass"), ("Adapt"), ("Assemble"), ("Abandon"), ("Activate"), ("Attach"), ("Seek"), ("Cast"), ("Counter"), ("Create"), ("Destroy"), ("Discard"), ("Double"), ("Exchange"), ("Exile"), ("Investigate"), ("Play"), ("Regenerate"), ("Reveal"), ("Sacrifice"), ("Set in motion"), ("Shuffle"), ("Tap"), ("Untap"), ("Vote"), ("Transform"), ("Surveil"), ("Goad"), ("Planeswalk"), ("Mill"), ("Learn"), ("Conjure"), ("Exert"), ("Connive"), ("Venture into the dungeon"), ("Convert"), ("Open an Attraction"), ("Roll to Visit Your Attractions");

-- SELECT * FROM `key_abilities` WHERE name IN ('vigilance', 'kicker', 'flying', 'lifelink', 'domain', 'read ahead'); -- для быстрого подбора id способностей

INSERT INTO `card_abilities` VALUES (2, 92), (3, 176), (3, 181), (3, 183), (4, 9), (7, 231);

-- ----------------------------------------------- Представления -------------------------------------------------

CREATE OR REPLACE VIEW all_cards AS
SELECT 
	c.`name`, 
	c.`number`, 
	s.`short name` AS `set`, 
	l.`short_name` AS `lang`, 
	c.`mana_cost` AS `cost`,
	c.`mana_value` AS `cmc`,
	c2.`name` AS `color`,
	r.`short_name` AS `rare`,
	CONCAT(t1.`name`, ' ',  IFNULL(t2.`name`,''), ' ', IFNULL(t3.`name`,''), ' ', IFNULL(t4.`name`,'')) AS `type`, 
	c.`body`,
	c.`power_toughness_loyality` AS `PTL`,
	c.`artist`,
	c.`flavor_text` AS `flavor` 
FROM `cards` c
JOIN `sets` s ON s.id = c.set_id 
JOIN `languages` l ON l.id = s.language_id 
JOIN `types_string` ts ON ts.id = c.type_string_id 
LEFT JOIN `types` t1 ON t1.id = ts.type_id_1
LEFT JOIN `types` t2 ON t2.id = ts.type_id_2
LEFT JOIN `types` t3 ON t3.id = ts.type_id_3
LEFT JOIN `types` t4 ON t4.id = ts.type_id_4
JOIN `rarities` r ON r.id = c.rarity_id 
JOIN `colors` c2 ON c2.id = c.color_id
LEFT JOIN `format_legal` fl ON fl.card_id = c.id 
ORDER BY `set`, c.`number`;

CREATE OR REPLACE VIEW cards_with_abilities AS
SELECT 
	c.`name`,
	GROUP_CONCAT(ka.name) AS 'abilities'
FROM `cards` c
LEFT JOIN `card_abilities` ca ON ca.card_id = c.id
LEFT JOIN `key_abilities` ka ON ca.key_ability_id = ka.id 
GROUP BY c.`name`
ORDER BY c.`name`;

CREATE OR REPLACE VIEW all_sets AS
SELECT 
	s.`name`,
	s.`short name`,
	s.`date`,
	GROUP_CONCAT(c.name) AS 'all_cards'
FROM `sets` s
LEFT JOIN `cards` c ON s.id = c.set_id
LEFT JOIN `languages` l ON l.id = s.language_id 
GROUP BY s.`name`
ORDER BY s.`name`;

SELECT * FROM all_cards;

SELECT * FROM cards_with_abilities;

SELECT * FROM all_sets;

-- -------------------------------------------------- Процедуры ---------------------------------------------------

-- Процедура добавления карт в базу
DROP PROCEDURE IF EXISTS mtg_cards.sp_card_add;
DELIMITER $$
$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `mtg_cards`.`sp_card_add`(IN `name` VARCHAR(50), `number` INT, `set` VARCHAR(10), `language` VARCHAR(10), 
`type1` VARCHAR(50), `type2` VARCHAR(20), `type3` VARCHAR(20), `type4` VARCHAR(20), `rarity` BIGINT, `mana cost` VARCHAR(20), `mana value` INT, 
`artist` VARCHAR(50), `body`  VARCHAR(255), `color` BIGINT, `ptl` VARCHAR(50), `flavor` VARCHAR(255), `standard` VARCHAR(20), `modern` VARCHAR(20), 
`legacy` VARCHAR(20), `vintage` VARCHAR(20), `commander` VARCHAR(20), `pauper` VARCHAR(20), OUT `tran_result` VARCHAR(100))
BEGIN
	DECLARE `_rollback` BIT DEFAULT b'0';
	DECLARE `code` VARCHAR(100);
	DECLARE `error_string` VARCHAR(100);

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN 
		SET `_rollback` = b'1';
		GET stacked DIAGNOSTICS CONDITION 1
		`code` = RETURNED_SQLSTATE, `error_string` = MESSAGE_TEXT;
	END;

	START TRANSACTION;
	INSERT INTO `types_string` VALUES (NULL, (SELECT t.`id` FROM `types` t WHERE t.`name` = `type1`), (SELECT t.`id` FROM `types` t 
	WHERE t.`name` = `type2`), (SELECT t.`id` FROM `types` t WHERE t.`name` = `type3`), (SELECT t.`id` FROM `types` t WHERE t.`name` = `type4`));

	INSERT INTO `cards` VALUES (NULL, `name`, `number`, (SELECT s.`id` FROM `sets` s WHERE s.`short name` = `set` AND s.`language_id` = 
	(SELECT l.`id` FROM `languages` l WHERE l.`short_name` = `language`)), last_insert_id(), `rarity`, `mana cost`, `mana value`, 
	`artist`, `body`, `color`, `ptl`, `flavor`);

	INSERT INTO `format_legal` VALUES (last_insert_id(), `standard`, `modern`, `legacy`, `vintage`, `commander`, `pauper`);

	IF `_rollback` THEN 
		SET `tran_result` = CONCAT('УПС. Ошибка: ', `code`, 'Текст ошибки: ', `error_string`);
		ROLLBACK;
	ELSE 
		SET `tran_result` = 'COMMIT';
		COMMIT;
	END IF;
END$$
DELIMITER ;

-- name, number, set, language, type1, type2, type3, type4, rarity, mana cost, mana value, artist, body, color, ptl, flavor, standard, modern, legacy, vintage, commander, pauper, @result
CALL sp_card_add('Illuminator Virtuoso', 017, 'SNC', 'EN', 'creature', 'human', 'rogue', NULL, 2, '1{W}', 2, 'John Stanko', 'Double strike. Whenever Illuminator Virtuoso becomes the target of a spell you control, it connives.', 1, '1/1', 'The Obscura reserve their keenest blades for traitors in their midst.', 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal', @`tran_result`);
SELECT @`tran_result`;

CALL sp_card_add('Angel of Sufferin', 067, 'SNC', 'EN', 'creature', 'nightmare', 'angel', NULL, 4, '3{B}{B}', 5, 'Martina Fackova', 'Flying. If damage would be dealt to you, prevent that damage and mill twice that many cards.', 5, '5/3', '“If you wish for blessings, mortal, ask your demon masters. We’ve given enough to your kind.”', 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Not legal', @`tran_result`);
SELECT @`tran_result`;

CALL sp_card_add('Wrecking Crew', 132, 'SNC', 'EN', 'creature', 'human', 'warrior', NULL, 1, '4{R}', 5, 'Joshua Raphael', 'Reach, trample', 4, '4/5', 'They built the neighborhood. They know its weak points. They know all the hiding places. When they come for you, they’ll find you and bring the roof down on your head.', 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', 'Legal', @`tran_result`);
SELECT @`tran_result`;

-- SELECT * FROM `key_abilities` WHERE name IN ('reach', 'trample', 'flying', 'double strike', 'connive'); -- для быстрого подбора id способностей

INSERT INTO `card_abilities` VALUES (11, 131), (11, 283), (12, 176), (13, 68), (13, 91); -- (!) не смог вписать в процедуру, т.к. не знаю как встроить перебор списка key_abilities с поиском в тексте поля body. Буду признателе если подскажите как это делать.

-- ----------------------------------------------------- Примеры запросов ----------------------------------------------------------

-- Найти всех белых существ и отсортировать по мана стоимости
SELECT `name`, `set`, `color`, `cost`, `rare`, `type` 
FROM `all_cards` 
WHERE `color` = 'White' AND `type` RLIKE 'Creature'
ORDER BY `cmc`;

-- Найти все карты со способностью Flying, отсортировать по мана стоимости
SELECT c.`name`, c.`mana_cost`, cwa.`abilities` 
FROM `cards` c 
LEFT JOIN `cards_with_abilities` cwa ON c.`name` = cwa.`name`  
WHERE cwa.`abilities` RLIKE 'Flying';

-- Найти все карты с эффектом Enter the battlefield
SELECT ac.`name`, ac.`set`, ac.`color`, ac.`cost`, ac.`rare`, ac.`type`, c.`body` 
FROM `all_cards` ac
JOIN `cards` c ON ac.`name` = c.`name` 
WHERE c.`body` RLIKE 'enters the battlefield';

-- Наёти все мифические черные карты
SELECT `name`, `set`, `color`, `cost`, `rare`, `type` 
FROM `all_cards` 
WHERE `color` = 'Black' AND `rare` = 'M';

-- Найти все карты с артом художника 
SELECT `name`, `set`, `rare`, `type`, `artist` 
FROM `all_cards` 
WHERE `artist` = 'Joshua Raphael';