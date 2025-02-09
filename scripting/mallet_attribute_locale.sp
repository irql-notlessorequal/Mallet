#include "mallet_int_map.sp"

enum MalletAttributeValueType
{
	mStringAttribute = 0,
	mFloatAttribute,
	mIntegerAttribute
}

/**
 * There used to be a nicer implementation here.
 * It was so """fast""" that Mallet would timeout on load, and if you bypassed that, the server's watchdog would trigger.
 * This is why I hate KeyValues.
 * 
 * tl;dr fuck SourcePawn and fuck your RAM usage
 */
IntMap __GenerateAttributeDescriptionDB()
{
	IntMap DB = new IntMap();
	DB.SetString(1, "%s1% damage penalty");
	DB.SetString(2, "+%s1% damage bonus");
	DB.SetString(3, "%s1% clip size");
	DB.SetString(4, "+%s1% clip size");
	DB.SetString(5, "%s1% slower firing speed");
	DB.SetString(6, "+%s1% faster firing speed");
	DB.SetString(7, "%s1% heal rate");
	DB.SetString(8, "+%s1% heal rate");
	DB.SetString(9, "%s1% ÜberCharge rate");
	DB.SetString(10, "+%s1% ÜberCharge rate");
	DB.SetString(11, "+%s1% max overheal");
	DB.SetString(12, "%s1% shorter overheal time");
	DB.SetString(13, "+%s1% longer overheal time");
	DB.SetString(14, "Overheal bonus doesn't decay");
	DB.SetString(15, "No random critical hits");
	DB.SetString(16, "On Hit: Gain up to +%s1 health");
	DB.SetString(17, "On Hit: %s1% ÜberCharge added");
	DB.SetString(18, "ÜberCharge grants 100% critical chance");
	DB.SetString(19, "On Hit: +%s1% damage bonus");
	DB.SetString(20, "100% critical hit vs burning players");
	DB.SetString(21, "%s1% damage vs non-burning players");
	DB.SetString(22, "No critical hits vs non-burning players");
	DB.SetString(23, "No compression blast");
	DB.SetString(24, "100% critical hits from behind");
	DB.SetString(26, "+%s1 max health on wearer");
	DB.SetString(27, "Attrib_AltFire_Disabled");
	DB.SetString(28, "No random critical hits");
	DB.SetString(30, "On Kill: +50 health on nearby teammates\n\nOn Kill: +10% Crit Chance on nearby teammates");
	DB.SetString(31, "On Kill: %s1 seconds of 100% critical chance");
	DB.SetString(32, "On Hit: %s1% chance to slow target");
	DB.SetString(33, "Cloak Type: Feign Death.\n\nLeave a fake corpse on taking damage and temporarily gain invisibility, speed, and damage resistance.");
	DB.SetString(34, "+%s1% cloak drain rate");
	DB.SetString(35, "+%s1% cloak regen rate");
	DB.SetString(36, "%s1% less accurate");
	DB.SetString(38, "Alt-Fire: Launches a ball that slows opponents");
	DB.SetString(39, "%s1% damage vs non-stunned players");
	DB.SetString(40, "No move speed penalty from zoom");
	DB.SetString(41, "+%s1% charge rate");
	DB.SetString(42, "No headshots");
	DB.SetString(43, "Attrib_Scattergun_NoReloadSingle");
	DB.SetString(44, "Knockback on the target and shooter");
	DB.SetString(45, "+%s1% bullets per shot");
	DB.SetString(46, "%s1% zoom reduction");
	DB.SetString(47, "No zoom or damage charge");
	DB.SetString(48, "Cloak Type: Motion Sensitive.\n\nAlt-fire: Turn invisible. Cannot attack while invisible. Bumping in to enemies will make you slightly visible to enemies. Cloak drain rate based on movement speed.");
	DB.SetString(49, "Disables double jump");
	DB.SetString(50, "Absorbs %s1% damage while cloaked");
	DB.SetString(51, "Crits on headshot");
	DB.SetString(52, "Blocks a single backstab attempt");
	DB.SetString(53, "Wearer cannot ignite");
	DB.SetString(54, "%s1% slower move speed on wearer");
	DB.SetString(56, "Coated enemies take mini-crits\n\nCan be used to extinguish fire");
	DB.SetString(57, "+%s1 health regenerated per second on wearer");
	DB.SetString(58, "+%s1% self damage force");
	DB.SetString(59, "%s1% self damage force");
	DB.SetString(60, "+%s1% fire damage resistance on wearer");
	DB.SetString(61, "%s1% fire damage vulnerability on wearer");
	DB.SetString(62, "+%s1% critical hit damage resistance on wearer");
	DB.SetString(63, "%s1% critical hit damage vulnerability on wearer");
	DB.SetString(64, "+%s1% explosive damage resistance on wearer");
	DB.SetString(65, "%s1% explosive damage vulnerability on wearer");
	DB.SetString(66, "+%s1% bullet damage resistance on wearer");
	DB.SetString(67, "%s1% bullet damage vulnerability on wearer");
	DB.SetString(68, "+%s1 capture rate on wearer");
	DB.SetString(69, "%s1% health from healers on wearer");
	DB.SetString(70, "+%s1% health from healers on wearer");
	DB.SetString(71, "+%s1% afterburn damage bonus");
	DB.SetString(72, "%s1% afterburn damage penalty");
	DB.SetString(73, "+%s1% afterburn duration");
	DB.SetString(74, "%s1% afterburn duration");
	DB.SetString(75, "+%s1% faster move speed while deployed");
	DB.SetString(76, "+%s1% max primary ammo on wearer");
	DB.SetString(77, "%s1% max primary ammo on wearer");
	DB.SetString(78, "+%s1% max secondary ammo on wearer");
	DB.SetString(79, "%s1% max secondary ammo on wearer");
	DB.SetString(80, "+%s1% max metal on wearer");
	DB.SetString(81, "%s1% max metal on wearer");
	DB.SetString(82, "-%s1% cloak duration");
	DB.SetString(83, "+%s1% cloak duration");
	DB.SetString(84, "+%s1% cloak regeneration rate");
	DB.SetString(85, "%s1% cloak regeneration rate");
	DB.SetString(86, "%s1% slower spin up time");
	DB.SetString(87, "%s1% faster spin up time");
	DB.SetString(88, "+%s1 max pipebombs out");
	DB.SetString(89, "%s1 max pipebombs out");
	DB.SetString(90, "%s1% faster power charge");
	DB.SetString(91, "%s1% slower power charge");
	DB.SetString(92, "Construction hit speed boost increased by %s1%");
	DB.SetString(93, "Construction hit speed boost decreased by %s1%");
	DB.SetString(94, "%s1% faster repair rate");
	DB.SetString(95, "%s1% slower repair rate");
	DB.SetString(96, "%s1% slower reload time");
	DB.SetString(97, "%s1% faster reload time");
	DB.SetString(98, "On Hit: %s1 health");
	DB.SetString(99, "+%s1% explosion radius");
	DB.SetString(100, "%s1% explosion radius");
	DB.SetString(101, "+%s1% projectile range");
	DB.SetString(102, "%s1% projectile range");
	DB.SetString(103, "+%s1% projectile speed");
	DB.SetString(104, "%s1% projectile speed");
	DB.SetString(105, "%s1% max overheal");
	DB.SetString(106, "%s1% more accurate");
	DB.SetString(107, "+%s1% faster move speed on wearer");
	DB.SetString(108, "+%s1% health from packs on wearer");
	DB.SetString(109, "%s1% health from packs on wearer");
	DB.SetString(110, "On Hit: Gain up to +%s1 health");
	DB.SetString(111, "On Hit: %s1 health");
	DB.SetString(112, "+%s1% ammo regenerated every 5 seconds on wearer");
	DB.SetString(113, "+%s1 metal regenerated every 5 seconds on wearer");
	DB.SetString(114, "Mini-crits targets launched airborne by explosions, grapple hooks or rocket packs");
	DB.SetString(115, "Damage increases as the user becomes injured");
	DB.SetString(116, "Attrib_SoldierBuffType");
	DB.SetString(117, "Attrib_Dmg_Falloff_Increased");
	DB.SetString(118, "%s1% splash damage fall off");
	DB.SetString(119, "Detonates stickybombs near the crosshair and directly under your feet");
	DB.SetString(120, "%s1 sec slower bomb arm time");
	DB.SetString(121, "Able to destroy enemy stickybombs");
	DB.SetString(122, "Attrib_DemoBuffType");
	DB.SetString(123, "%s1% speed boost while active weapon");
	DB.SetString(124, "Replaces the Sentry with a Mini-Sentry");
	DB.SetString(125, "%s1 max health on wearer");
	DB.SetString(126, "%s1 sec faster bomb arm time");
	DB.SetString(127, "Launched bombs shatter on surfaces");
	DB.SetString(128, "When weapon is active:");
	DB.SetString(129, "%s1 health drained per second on wearer");
	DB.SetString(130, "+%s1% natural regen rate");
	DB.SetString(131, "-%s1% natural regen rate");
	DB.SetString(132, "Given to valuable Community Contributors");
	DB.SetString(133, "Medal no. %s1");
	DB.SetString(134, "★ Unusual Effect: %s1");
	DB.SetString(135, "%s1% blast damage from rocket jumps");
	DB.SetString(136, "Gain 2 revenge crits for each sentry kill and\n\n1 for each sentry assist when your sentry is destroyed.");
	DB.SetString(137, "+%s1% damage vs buildings");
	DB.SetString(138, "%s1% damage vs players");
	DB.SetString(139, "Adds +50 max health for 30 seconds");
	DB.SetString(140, "+%s1 max health on wearer");
	DB.SetString(141, "I made this!");
	DB.SetString(142, "Item tint color code: %s1");
	DB.SetString(143, "Hire Date: %s1");
	DB.SetString(144, "Sets weapon mode #%s1");
	DB.SetString(145, "%s1% damage penalty");
	DB.SetString(146, "Damage removes Sappers");
	DB.SetString(147, "Wrench no. %s1");
	DB.SetString(148, "%s1 metal reduction in building cost");
	DB.SetString(149, "On Hit: Bleed for %s1 seconds");
	DB.SetString(150, "Imbued with an ancient power");
	DB.SetString(151, "Attrib_Socket");
	DB.SetString(152, "Custom Texture");
	DB.SetString(153, "Not Tradable or Marketable");
	DB.SetString(154, "Upon a successful backstab against a human target, you rapidly disguise as your victim");
	DB.SetString(155, "Wearer cannot disguise");
	DB.SetString(156, "Silent Killer: No attack noise from backstabs");
	DB.SetString(157, "%s1 sec slower disguise speed");
	DB.SetString(158, "+%s1% cloak on kill");
	DB.SetString(159, "%s1 sec longer cloak blink time");
	DB.SetString(160, "Reduced decloak sound volume");
	DB.SetString(161, "%s1% less flame spread area");
	DB.SetString(162, "+%s1% more flame spread area");
	DB.SetString(163, "%s1% less flame distance");
	DB.SetString(164, "+%s1% more flame distance");
	DB.SetString(165, "Airblast can now be charged, which will push enemies further");
	DB.SetString(166, "+%s1% cloak on hit");
	DB.SetString(167, "Attrib_DisguiseDamageReduction");
	DB.SetString(168, "Immune to fire damage while disguised");
	DB.SetString(169, "+%s1% sentry damage resistance on wearer");
	DB.SetString(170, "+%s1% airblast cost");
	DB.SetString(171, "%s1% airblast cost");
	DB.SetString(172, "Purchased: Not Tradable, Marketable, or Usable in Crafting");
	DB.SetString(173, "+%s1% flamethrower ammo consumed per second");
	DB.SetString(174, "%s1% flamethrower ammo consumed per second");
	DB.SetString(175, "On Scoped Hit: Apply Jarate for 2 to %s1 seconds based on charge level.\n\nNature's Call: Scoped headshots always mini-crits and reduce the remaining cooldown of Jarate by 1 second.");
	DB.SetString(176, "The wearer cannot be killed by headshots");
	DB.SetString(177, "%s1% longer weapon switch");
	DB.SetString(178, "%s1% faster weapon switch");
	DB.SetString(179, "Crits whenever it would normally mini-crit");
	DB.SetString(180, "+%s1 health restored on kill");
	DB.SetString(181, "No self inflicted blast damage taken");
	DB.SetString(182, "On Hit: Slow target movement by 40% for %s1s");
	DB.SetString(183, "%s1% slower move speed while deployed");
	DB.SetString(184, "Attrib_DuelLoserAccountID");
	DB.SetString(185, "Date Received: %s1");
	DB.SetString(186, "Gift from: %s1");
	DB.SetString(187, "Crate Series #%s1");
	DB.SetString(188, "On death up to %s1% of your stored\n\nÜberCharge is retained");
	DB.SetString(189, "Attrib_ElevateQuality");
	DB.SetString(190, "+%s1 health regenerated per second on wearer");
	DB.SetString(191, "%s1 health drained per second on wearer");
	DB.SetString(194, "Contains: %s1");
	DB.SetString(195, "Always Tradable");
	DB.SetString(196, "Noise Maker");
	DB.SetString(197, "This is a special Halloween %s1 item");
	DB.SetString(198, "This is a special Halloween %s1 item");
	DB.SetString(199, "This weapon holsters %s1% faster");
	DB.SetString(200, "Alt-Fire: Applies a healing effect to all nearby teammates");
	DB.SetString(201, "+%s1% faster taunt speed on wearer");
	DB.SetString(202, "%s1 sec increase in charge duration");
	DB.SetString(203, "On Kill: A small health pack is dropped");
	DB.SetString(204, "On Miss: Hit yourself. Idiot.");
	DB.SetString(205, "%s1% damage from ranged sources while active");
	DB.SetString(206, "+%s1% damage from melee sources while active");
	DB.SetString(207, "+%s1% damage to self");
	DB.SetString(208, "On Hit: target is engulfed in flames");
	DB.SetString(209, "100% minicrits vs burning players");
	DB.SetString(211, "Tradable After: %s1");
	DB.SetString(216, "Attrib_Knockback");
	DB.SetString(217, "On Backstab: Absorbs the health from your victim.");
	DB.SetString(218, "On Hit: One target at a time is Marked-For-Death, causing all damage taken to be mini-crits");
	DB.SetString(219, "%s1% damage penalty");
	DB.SetString(220, "On Kill: Gain %s1% of base health on kill");
	DB.SetString(221, "Attrib_DecloakRate");
	DB.SetString(222, "On Scoped Bodyshot: Rifle charge rate increased by %s1%");
	DB.SetString(223, "On Scoped Miss: Rifle charge rate decreased by %s1%");
	DB.SetString(224, "%s1% increase in damage when health <50% of max");
	DB.SetString(225, "%s1% decrease in damage when health >50% of max");
	DB.SetString(226, "Honorbound: Once drawn sheathing deals 50 damage to yourself unless it kills.");
	DB.SetString(227, "Custom Texture");
	DB.SetString(228, "Crafted by %s1");
	DB.SetString(230, "When the medic healing you is killed you\n\ngain 2 revenge crits");
	DB.SetString(231, "ÜberCharge increases healing to 300% and grants immunity to movement-impairing effects");
	DB.SetString(232, "When the medic healing you is killed\n\nyou gain mini-crit boost for %s1 seconds");
	DB.SetString(233, "While a medic is healing you,\n\nthis weapon's damage is increased by %s1%");
	DB.SetString(234, "While not being healed by a medic,\n\nyour weapon switch time is %s1% longer");
	DB.SetString(235, "Move speed increases as the user becomes injured");
	DB.SetString(236, "Blocks healing while in use");
	DB.SetString(237, "On Scoped Headshot: Rifle charge rate increased by %s1%");
	DB.SetString(238, "Silent Killer: No barrel spin sound");
	DB.SetString(239, "+%s1% ÜberCharge rate for the medic healing you\n\nThis effect does not work in the respawn room");
	DB.SetString(240, "%s1% faster reload time while being healed");
	DB.SetString(241, "%s1% slower reload time");
	DB.SetString(242, "When the medic healing you is killed\n\nthe killer becomes Marked-For-Death");
	DB.SetString(243, "%s1% rage lost on hit");
	DB.SetString(244, "%s1% rage gained on hit");
	DB.SetString(245, "Gains a damage bonus as rage increases, up to %s1%");
	DB.SetString(246, "+%s1% increase in turning control while charging");
	DB.SetString(247, "Can deal charge impact damage at any range");
	DB.SetString(248, "+%s1% increase in charge impact damage");
	DB.SetString(249, "+%s1% increase in charge recharge rate");
	DB.SetString(250, "Grants Triple Jump while deployed.\n\nMelee attacks mini-crit while airborne.");
	DB.SetString(251, "On Hit Teammate: Boosts both players' speed for several seconds");
	DB.SetString(252, "%s1% reduction in push force taken from damage");
	DB.SetString(253, "%s1 sec increase in time to cloak");
	DB.SetString(255, "+%s1% airblast push force");
	DB.SetString(258, "Ammo collected from ammo boxes becomes health");
	DB.SetString(259, "Deals 3x falling damage to the player you land on");
	DB.SetString(260, "Attrib_DeflectionSizeMultiplier");
	DB.SetString(261, "Item tint color code: %s1");
	DB.SetString(262, "Winner: %s1 %s2");
	DB.SetString(264, "%s1% increased melee attack range");
	DB.SetString(265, "Attrib_MiniCritAirborneEnemiesDeploy");
	DB.SetString(266, "Projectiles penetrate enemy players");
	DB.SetString(267, "Deals crits while the wielder is rocket jumping");
	DB.SetString(268, "Base charge rate decreased by %s1%");
	DB.SetString(269, "Allows you to see enemy health");
	DB.SetString(270, "Holds a maximum of %s1 charges");
	DB.SetString(271, "Currently holds %s1 charges");
	DB.SetString(272, "Each charge lasts %s1 seconds");
	DB.SetString(273, "Consumable: Become Crit Boosted for 5 seconds\n\n(and double your sentry's firing speed)");
	DB.SetString(274, "Consumable: Become Übercharged for 5 seconds\n\n(and shield your sentry from damage)");
	DB.SetString(275, "Wearer never takes falling damage");
	DB.SetString(276, "Teleporters can be used in both directions");
	DB.SetString(277, "Attrib_MultipleSentries");
	DB.SetString(278, "+%s1% increase in recharge rate");
	DB.SetString(279, "+%s1% max misc ammo on wearer");
	DB.SetString(280, "Overrides the projectile fired from the weapon. Takes values from 1 to 26, each representing a different projectile, and not all projectiles work on all weapons");
	DB.SetString(281, "Does not require ammo");
	DB.SetString(282, "Alt-Fire: A charged shot that\n\nmini-crits players, sets them on fire, and disables buildings for 4 sec");
	DB.SetString(283, "Projectile penetrates enemy targets");
	DB.SetString(284, "Deals only 20% damage to buildings");
	DB.SetString(285, "Projectile cannot be deflected");
	DB.SetString(286, "+%s1% max building health");
	DB.SetString(287, "+%s1% Sentry Gun damage bonus");
	DB.SetString(288, "Cannot be crit boosted");
	DB.SetString(289, "Attrib_CenterFireProjectile");
	DB.SetString(296, "Gives one guaranteed critical hit for each\n\nbuilding destroyed with your sapper attached or backstab kill");
	DB.SetString(297, "Cannot fire unless zoomed");
	DB.SetString(298, "Per Shot: -%s1 ammo");
	DB.SetString(299, "On Hit: damage dealt is returned as ammo");
	DB.SetString(300, "Alt-Fire: Launches a projectile-consuming energy ball. Costs 65 metal.");
	DB.SetString(301, "Uses metal for ammo");
	DB.SetString(302, "This item will expire on %s1.");
	DB.SetString(304, "On Full Charge: +%s1% damage per shot");
	DB.SetString(305, "Fires tracer rounds");
	DB.SetString(306, "No headshots when not fully charged");
	DB.SetString(307, "No reload necessary");
	DB.SetString(308, "On Full Charge: Projectiles penetrate players");
	DB.SetString(309, "Killing an enemy with a critical hit will dismember your victim. Painfully.");
	DB.SetString(310, "Consumable: Instantly teleport to spawn");
	DB.SetString(311, "Unlimited use");
	DB.SetString(313, "%s1% movement speed on targets");
	DB.SetString(314, "Über duration increased %s1 seconds");
	DB.SetString(315, "Consumable: Instantly refill all weapon clips and ammo");
	DB.SetString(317, "Attrib_AlternateRocketEffect");
	DB.SetString(318, "+%s1% faster reload time");
	DB.SetString(319, "+%s1% buff duration");
	DB.SetString(320, "Increased robot Sapper radius and duration");
	DB.SetString(321, "+%s1% faster build speed");
	DB.SetString(322, "%s1% damage penalty");
	DB.SetString(323, "Bullets destroy rockets and grenades in-flight. Increased accuracy and frequency per-level.");
	DB.SetString(324, "Accuracy scales damage");
	DB.SetString(325, "+%s1% bonus currency from packs");
	DB.SetString(326, "+%s1% greater jump height when active");
	DB.SetString(327, "Consumable: Instantly upgrade all buildings to max level");
	DB.SetString(329, "%s1% reduction in airblast vulnerability");
	DB.SetString(334, "Explode spectacularly on death");
	DB.SetString(335, "+%s1% clip size");
	DB.SetString(336, "Unable to see enemy health");
	DB.SetString(337, "On Hit: Victim loses up to %s1% Medigun charge");
	DB.SetString(338, "On Hit: Victim loses up to %s1% cloak");
	DB.SetString(339, "On Hit Spy: Reveal cloaked Spy");
	DB.SetString(340, "On Hit Spy: Reveal disguised Spy");
	DB.SetString(341, "When backstabbed: Jarate attacker");
	DB.SetString(343, "+%s1% sentry firing speed");
	DB.SetString(344, "+%s1% sentry range");
	DB.SetString(345, "+%s1% dispenser range");
	DB.SetString(346, "Alt-Fire: Launches a festive ornament that shatters causing bleed");
	DB.SetString(347, "Backstab turns victim to ice");
	DB.SetString(351, "Build +%s1 additional disposable-sentry");
	DB.SetString(352, "Press your reload key to choose to teleport to spawn or your exit teleporter");
	DB.SetString(353, "Cannot carry buildings");
	DB.SetString(354, "Stuns enemies who are also wielding this weapon");
	DB.SetString(355, "Per Shot Missed: -%s1 ammo");
	DB.SetString(356, "No airblast");
	DB.SetString(357, "+%s1% buff duration");
	DB.SetString(358, "Critical hit forces victim to laugh");
	DB.SetString(359, "Melts in fire, regenerates in %s1 seconds and by picking up ammo");
	DB.SetString(360, "All players connected via Medigun beams are hit");
	DB.SetString(361, "On Hit by Fire: Fireproof for 1 second and Afterburn immunity for %s1 seconds");
	DB.SetString(362, "Always critical hit from behind");
	DB.SetString(363, "Critical hits do no damage");
	DB.SetString(364, "Jingle all the way");
	DB.SetString(365, "Attrib_SetIcicleKnifeMode");
	DB.SetString(366, "On Hit: If enemy's belt is at or above eye level,\n\nstun them for %s1 seconds");
	DB.SetString(367, "Alt-Fire: Extinguish teammates to gain guaranteed critical hits");
	DB.SetString(368, "Build 'Mmmph' by dealing damage.\n\nAlt-Fire on full 'Mmmph': Taunt to gain crits for several seconds. Invulnerable while 'Mmmph' taunting.");
	DB.SetString(369, "On Hit: Force enemies to laugh who are also wearing this item");
	DB.SetString(371, "Attrib_TauntSoundSuccess");
	DB.SetString(372, "A perpetual bond of commitment between %s1");
	DB.SetString(373, "and %s1, forever and ever and ever. XoXoX");
	DB.SetString(374, "Usable After: %s1");
	DB.SetString(375, "Generate Rage by dealing damage. When fully charged, press the Special-Attack key to activate knockback");
	DB.SetString(376, "No flinching when aiming and fully charged");
	DB.SetString(377, "Knockback reduced by %s1% when aiming");
	DB.SetString(378, "%s1% slower move speed when aiming");
	DB.SetString(387, "Gain Focus on kills and assists");
	DB.SetString(389, "Shots go through multiple enemies");
	DB.SetString(390, "Headshots deal an extra +%s1% damage");
	DB.SetString(391, "Reduces mystery solving time by up to %s1%");
	DB.SetString(392, "%s1% damage on body shot");
	DB.SetString(393, "Press 'Reload' to activate focus\n\nIn Focus: +25% faster charge and no unscoping");
	DB.SetString(394, "+%s1% faster firing speed");
	DB.SetString(395, "Increased headshot explosion radius and damage to nearby enemies");
	DB.SetString(396, "+%s1% faster melee attack speed");
	DB.SetString(397, "Bullets penetrate +%s1 enemies");
	DB.SetString(398, "Attrib_RageGainOnAssists");
	DB.SetString(399, "Increase backstab damage against Giant Robots by %s1%");
	DB.SetString(400, "Wearer cannot carry the intelligence briefcase or PASS Time JACK");
	DB.SetString(401, "Reduces chance of hunger by up to %s1%");
	DB.SetString(402, "Cannot be backstabbed");
	DB.SetString(403, "Squad surplus claimed by: %s1");
	DB.SetString(404, "Using your Power Up Canteen will apply the same bonus effect to your heal target");
	DB.SetString(405, "Attrib_AirBlastVerticalVulnerabilityMultipier");
	DB.SetString(407, "100% critical hit vs disguised players");
	DB.SetString(408, "100% critical hit vs non-burning players");
	DB.SetString(409, "On Kill: Burst into joyous laughter");
	DB.SetString(410, "+%s1% damage bonus while disguised");
	DB.SetString(411, "+%s1 degrees random projectile deviation");
	DB.SetString(412, "%s1% damage vulnerability on wearer");
	DB.SetString(413, "Hold Fire to load up to three rockets\n\nRelease Fire to unleash the barrage");
	DB.SetString(414, "You are Marked-For-Death while active, and for short period after switching weapons");
	DB.SetString(416, "Flare knocks back target on hit\n\nand explodes when it hits the ground. Increased knock back on burning players");
	DB.SetString(417, "Overloading the chamber will cause a misfire");
	DB.SetString(418, "On Hit: Builds Boost\n\nRun speed increased with Boost");
	DB.SetString(419, "Boost reduced on air jumps");
	DB.SetString(420, "Witnessed the %s1 inferno");
	DB.SetString(421, "No ammo from dispensers when active");
	DB.SetString(422, "Only visible in Pyroland");
	DB.SetString(424, "%s1% clip size");
	DB.SetString(425, "+%s1% sapper damage bonus");
	DB.SetString(426, "%s1% sapper damage penalty");
	DB.SetString(427, "+%s1 health regenerated per second for each active sapper");
	DB.SetString(428, "%s1% sapper health bonus");
	DB.SetString(429, "%s1% sapper health penalty");
	DB.SetString(430, "Creates a ring of flames while spun up");
	DB.SetString(431, "Consumes an additional %s1 ammo per second while spun up");
	DB.SetString(433, "Reverses enemy building construction");
	DB.SetString(434, "%s1% sapper damage penalty");
	DB.SetString(435, "Throw at your enemies to make them bleed!\n\nLong distance hits reduce recharge time");
	DB.SetString(437, "100% critical hit vs stunned players");
	DB.SetString(438, "100% critical hit vs wet players");
	DB.SetString(440, "+%s1 clip size");
	DB.SetString(441, "Attrib_AutoFiresFullClipAllAtOnce");
	DB.SetString(444, "Disables double jump");
	DB.SetString(445, "On Equip: Visit Pyroland");
	DB.SetString(448, "Attrib_PlayerSkinOverride");
	DB.SetString(451, "Attrib_Sapper_Voice_Pak");
	DB.SetString(452, "Attrib_Sapper_Voice_Pak_Idle_Wait");
	DB.SetString(453, "Killed Merasmus at level %s1");
	DB.SetString(464, "Sentry build speed increased by %s1%");
	DB.SetString(465, "Increases teleporter build speed by %s1%.");
	DB.SetString(466, "Cannonballs have a fuse time of 1 second; fuses can be primed to explode earlier by holding down the fire key.");
	DB.SetString(467, "Cannonballs do not explode on impact");
	DB.SetString(469, "Alt-Fire: Use %s1 metal to pick up your targeted building from long range");
	DB.SetString(470, "%s1% damage on contact with surfaces");
	DB.SetString(471, "Generate building rescue energy on damage");
	DB.SetString(472, "Self mark for death when hauling buildings");
	DB.SetString(473, "Press your reload key to cycle through resist types.\n\nWhile healing, provides you and your target with a constant 10% resistance to the selected damage type.");
	DB.SetString(474, "Fires a special bolt that can repair friendly buildings");
	DB.SetString(475, "+%s1% projectile speed");
	DB.SetString(476, "+%s1% damage bonus");
	DB.SetString(477, "Cannonballs push players back on impact");
	DB.SetString(479, "%s1% Overheal build rate.");
	DB.SetString(481, "Share Canteens with your heal target.\n\n+1 duration, -10 price per point (minimum cost: 5)");
	DB.SetString(482, "+25% more overheal, +50% longer duration per point");
	DB.SetString(484, "Syringes deliver a highly concentrated dose of Mad Milk. Duration increases per hit to a max of 4 seconds.");
	DB.SetString(488, "+15% rocket speed per point. On direct hits: rocket does maximum damage, stuns target, and blast radius increased +15% per point.");
	DB.SetString(489, "+%s1% faster move speed on wearer");
	DB.SetString(490, "+%s1 health regenerated per second on wearer");
	DB.SetString(491, "+%s1% critical hit damage resistance on wearer");
	DB.SetString(492, "+%s1% fire damage resistance on wearer");
	DB.SetString(493, "+25% heal rate for patient, +25% faster revive rate, and +25% self heal rate, per point");
	DB.SetString(499, "Build energy by healing teammates. When fully charged, press the Special-Attack key to deploy a frontal projectile shield.");
	DB.SetString(516, "%s1% bullet damage vulnerability on wearer");
	DB.SetString(517, "+%s1 max health on wearer");
	DB.SetString(524, "+%s1% greater jump height when active");
	DB.SetString(525, "%s1% increase in push force taken from damage");
	DB.SetString(526, "+%s1% bonus healing from all sources");
	DB.SetString(527, "Immune to the effects of afterburn.");
	DB.SetString(532, "Hype Decays Over Time.");
	DB.SetString(533, "Extra effects when taunting.");
	DB.SetString(534, "%s1% reduction in airblast vulnerability");
	DB.SetString(535, "%s1% increase in push force taken from damage");
	DB.SetString(536, "Increase in push force taken from damage and airblast");
	DB.SetString(537, "Leave a Calling Card on your victims.");
	DB.SetString(540, "Attrib_AddHeadOnHit");
	DB.SetString(547, "This weapon deploys %s1% faster");
	DB.SetString(554, "Revive Teammates");
	DB.SetString(606, "Attrib_TauntSoundSuccess");
	DB.SetString(607, "Attrib_PhaseCloak");
	DB.SetString(608, "Attrib_TauntSoundSuccess");
	DB.SetString(609, "Attrib_PhaseCloak");
	DB.SetString(610, "%s1% increased air control.");
	DB.SetString(612, "Attrib_RocketLaunchImpulse");
	DB.SetString(613, "On Kill: Gain Mini-crits for %s1 seconds.");
	DB.SetString(614, "No metal from dispensers when active.");
	DB.SetString(619, "Mini-crits targets when fired at their back from close range");
	DB.SetString(621, "Increased attack speed and smaller blast radius while blast jumping");
	DB.SetString(630, "Attrib_BackHeadshot");
	DB.SetString(632, "Fires 3 barrages while explosive jumping");
	DB.SetString(634, "Attrib_AirJumpOnAttack");
	DB.SetString(636, "Charge and fire shots independent of zoom");
	DB.SetString(637, "Zoom does not affect charge");
	DB.SetString(638, "100% critical hits burning players from behind.\n\nMini-crits burning players from the front.");
	DB.SetString(639, "Full turning control while charging");
	DB.SetString(643, "%s1% blast damage from rocket jumps");
	DB.SetString(644, "Clip size increased on kill");
	DB.SetString(647, "Fires tracer rounds");
	DB.SetString(651, "Fire rate increases as health decreases");
	DB.SetString(661, "Rewarded for participating in the 2014 Summer Adventure.");
	DB.SetString(669, "Stickybombs fizzle %s1 seconds after landing");
	DB.SetString(670, "Max charge time decreased by %s1%");
	DB.SetString(671, "Grenades have very little bounce and roll");
	DB.SetString(674, "Attrib_Class_Select_Override_VCD");
	DB.SetString(676, "Taking damage while shield charging reduces remaining charging time");
	DB.SetString(684, "%s1% damage on grenades that explode on timer");
	DB.SetString(693, "Increased Melee damage against Isolated Merc Set");
	DB.SetString(694, "Increased Nostromo Napalmer damage taken from Isolated Merc Set");
	DB.SetString(695, "Increased Nostromo Napalmer damage against Isolationist Pack Set");
	DB.SetString(696, "Increased Melee damage taken from Isolationist Pack Set");
	DB.SetString(701, "Duck XP Level: %s1");
	DB.SetString(702, "Duck Power: %s1 / 5");
	DB.SetString(703, "Early Supporter of End of the Line Community Update");
	DB.SetString(705, "Duckstreaks Active");
	DB.SetString(708, "Hold fire to load up to 4 shells");
	DB.SetString(709, "Weapon spread increases as health decreases");
	DB.SetString(710, "Attrib_AutoFiresFullClipNegative");
	DB.SetString(711, "Attrib_AutoFiresWhenFull");
	DB.SetString(726, "%s1% cloak meter when Feign Death is activated");
	DB.SetString(727, "Up to +%s1% damage based on charge");
	DB.SetString(728, "No cloak meter from ammo boxes when invisible");
	DB.SetString(729, "%s1% cloak meter from ammo boxes");
	DB.SetString(730, "Attrib_ElevateQuality");
	DB.SetString(732, "%s1% less metal from pickups and dispensers");
	DB.SetString(733, "Boost reduced when hit");
	DB.SetString(734, "%s1% less healing from all sources");
	DB.SetString(735, "100% critical hit vs burning players");
	DB.SetString(736, "Gain a speed boost on kill");
	DB.SetString(737, "On Hit: Gain a speed boost");
	DB.SetString(738, "%s1% damage resistance when below 50% health and spun up");
	DB.SetString(739, "%s1% ÜberCharge rate on Overhealed patients");
	DB.SetString(740, "%s1% less healing from Medic sources");
	DB.SetString(741, "On Hit: Gain up to +%s1 health per attack");
	DB.SetString(745, "Team Colored Decorated Weapon");
	DB.SetString(748, "Items Traded in: %s1");
	DB.SetString(772, "This weapon holsters %s1% slower");
	DB.SetString(773, "This weapon deploys %s1% slower");
	DB.SetString(774, "%s1 sec decrease in charge duration");
	DB.SetString(775, "%s1% damage penalty vs buildings");
	DB.SetString(776, "%s1% decrease in charge impact damage");
	DB.SetString(777, "Not Tradable, Marketable, Usable in Crafting, or Gift Wrappable");
	DB.SetString(778, "Melee hits refill %s1% of your charge meter.");
	DB.SetString(779, "Secondary fire when charged grants mini-crits for %s1 seconds.");
	DB.SetString(780, "Dealing damage fills charge meter.");
	DB.SetString(781, "This Weapon has a large melee range and\n\ndeploys and holsters slower");
	DB.SetString(782, "Ammo boxes collected also give Charge");
	DB.SetString(783, "Extinguishing teammates restores %s1 health");
	DB.SetString(784, "Extinguishing teammates reduces cooldown by %s1%");
	DB.SetString(787, "%s1% fuse time on grenades");
	DB.SetString(788, "+%s1% faster move speed on wearer (shield required)");
	DB.SetString(789, "%s1% increased damage to your sentry's target");
	DB.SetString(790, "%s1% metal cost when constructing or upgrading teleporters");
	DB.SetString(791, "Attrib_DamageBlastPush");
	DB.SetString(793, "On Hit: Builds Hype");
	DB.SetString(794, "+%s1% fire damage resistance while deployed");
	DB.SetString(795, "%s1% damage bonus vs burning players");
	DB.SetString(797, "Attacks pierce damage resistance effects and bonuses");
	DB.SetString(798, "+%s1% damage vulnerability while active");
	DB.SetString(799, "Revenge crits are lost on death");
	DB.SetString(800, "%s1% maximum overheal on wearer");
	DB.SetString(807, "Collect the organs of your victims");
	DB.SetString(808, "Successive shots become less accurate");
	DB.SetString(809, "Fires a wide, fixed shot pattern");
	DB.SetString(810, "Attrib_NoCloakFromAmmo");
	DB.SetString(811, "Collect the organs of people you hit");
	DB.SetString(812, "%s1% increased air control when blast jumping.");
	DB.SetString(813, "Immune to push force from damage and airblast when spun up");
	DB.SetString(816, "Normal disguises require (and consume) a full cloak meter");
	DB.SetString(822, "Attrib_AirblastDestroyProjectile");
	DB.SetString(848, "Spawning and resupply do not affect the Gas meter");
	DB.SetString(851, "+%s1% faster move speed on wearer");
	DB.SetString(852, "%s1% damage vulnerability on wearer");
	DB.SetString(853, "%s1% maximum overheal on wearer");
	DB.SetString(854, "%s1% health from healers on wearer");
	DB.SetString(855, "Maximum health is drained while item is active");
	DB.SetString(868, "Critical damage is affected by range");
	DB.SetString(869, "Minicrits whenever it would normally crit");
	DB.SetString(870, "Push enemies back when you land (force and radius based on velocity)");
	DB.SetString(871, "Stun enemies when you land");
	DB.SetString(872, "Able to re-launch while already in-flight");
	DB.SetString(874, "%s1% faster recharge rate");
	DB.SetString(875, "Ignited enemies explode");
	DB.SetString(876, "%s1% healing effect");
	DB.SetString(877, "Gain a speed boost when you hit an enemy player");
	DB.SetString(878, "Gas meter starts empty");
	DB.SetString(879, "Gas meter builds with damage done and/or time");
	DB.SetString(880, "%s1-to-1 health-to-metal ratio when repairing buildings");
	DB.SetString(881, "%s1 health regenerated per second on wearer");
	DB.SetString(1000, "+%s1% damage bonus");
	DB.SetString(1001, "+%s1% bullet damage resistance on wearer");
	DB.SetString(1002, "+%s1% faster move speed on wearer");
	DB.SetString(1003, "+%s1 health regenerated per second on wearer");
	DB.SetString(1004, "%s1");
	DB.SetString(1005, "%s1");
	DB.SetString(1006, "Voices From Below");
	DB.SetString(1007, "Pumpkin Bombs");
	DB.SetString(1008, "Halloween Fire");
	DB.SetString(1009, "Exorcism");
	DB.SetString(2013, "Killstreaker: %s1");
	DB.SetString(2014, "Sheen: %s1");
	DB.SetString(2016, "Pages of Tumidum: %s1");
	DB.SetString(2017, "Pages of Gratanter: %s1");
	DB.SetString(2018, "Pages of Audere: %s1");
	DB.SetString(2019, "Pages of Congeriae: %s1");
	DB.SetString(2020, "Pages of Veteris: %s1");
	DB.SetString(2025, "Killstreaks Active");
	DB.SetString(2034, "Melee kills refill %s1% of your charge meter.");
	DB.SetString(2041, "★ Unusual Effect: %s1");
	DB.SetString(2043, "%s1% slower upgrade rate");
	DB.SetString(2048, "Disables double jump");
	DB.SetString(2049, "Third successful punch in a row always crits.");
	DB.SetString(2053, "Festivized");
	DB.SetString(2063, "Deals 300% damage to burning players\n\n+50% re-pressurization rate on hit");
	DB.SetString(2064, "-50% repressurization rate on Alt-Fire");
	DB.SetString(2065, "Uses a shared pressure tank for Primary Fire and Alt-Fire.\n\nPrimary Fire: Launches a fast-moving projectile that briefly ignites enemies Alt-Fire: Release a blast of air that pushes enemies and projectiles, and extinguishes teammates that are on fire.");
	DB.SetString(2067, "Mini-crits burning targets and extinguishes them. Damage increases based on remaining duration of afterburn.\n\nKilling blows on burning players grant a speed boost.");
	return DB;
}

static IntMap ATTRIBUTE_DESCRIPTION_DB;

bool InternalGetRawAttributeDescription(int iDefIndex, char[] value, int valueSize)
{
	if (ATTRIBUTE_DESCRIPTION_DB == null)
	{
		ATTRIBUTE_DESCRIPTION_DB = __GenerateAttributeDescriptionDB();
	}

	return ATTRIBUTE_DESCRIPTION_DB.GetString(iDefIndex, value, valueSize);
}

/* native bool MalletGetRawAttributeDescription(int key, char[] value, int valueSize) */
public int Native_GetRawAttributeDescription(Handle plugin, int numParams)
{
#if defined(MALLET_DISABLE_ATTRIBUTE_LOCALE)
	return ThrowNativeError(SP_ERROR_NATIVE, "GetRawAttributeDescription is unavailable in this Mallet build.");
#else
	if (numParams != 3)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int key = GetNativeCell(1);
	int valueSize = GetNativeCell(3);

	if (valueSize <= 0 || valueSize > 2048)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid valueSize (%i)", valueSize);
	}

	char[] strAttrib = new char[valueSize];
	GetNativeString(2, strAttrib, valueSize);

	bool retValue = InternalGetRawAttributeDescription(key, strAttrib, valueSize);
	SetNativeString(2, strAttrib, valueSize);

	return retValue;
#endif
}

/* native bool MalletGetAttributeDescription(int key, char[] value, int valueSize, MalletAttributeValueType type, any attributeValue) */
public int Native_GetAttributeDescription(Handle plugin, int numParams)
{
#if defined(MALLET_DISABLE_ATTRIBUTE_LOCALE)
	return ThrowNativeError(SP_ERROR_NATIVE, "GetAttributeDescription is unavailable in this Mallet build.");
#else
	if (numParams != 5)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int key = GetNativeCell(1);
	int valueSize = GetNativeCell(3);
	MalletAttributeValueType type = view_as<MalletAttributeValueType>(GetNativeCell(4));

	if (valueSize <= 0 || valueSize > 2048)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid valueSize (%i)", valueSize);
	}

	char[] strAttrib = new char[valueSize];
	char valueBuffer[16];
	
	switch (type)
	{
		case mStringAttribute:
		{
			int len;
			GetNativeStringLength(5, len);
			char[] attributeStr = new char[len];
			GetNativeString(5, attributeStr, len);
			PopulateValueBufferStr(valueBuffer, attributeStr);
		}
		case mIntegerAttribute:
		{
			any attributeValue = GetNativeCell(5);
			PopulateValueBufferInt(valueBuffer, attributeValue);
		}
		case mFloatAttribute:
		{
			any attributeValue = GetNativeCell(5);
			PopulateValueBufferFloat(valueBuffer, attributeValue);
		}
		default:
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid attribute type!");
		}
	}

	if (!InternalGetRawAttributeDescription(key, strAttrib, valueSize))
		return false;

	/* Ignore zero matches, we might not have an actual value to put in there. */
	ReplaceString(strAttrib, valueSize, "%s1", valueBuffer);
	SetNativeString(2, strAttrib, valueSize);
	return true;
#endif
}

void PopulateValueBufferStr(char valueBuffer[16], char[] value)
{
	strcopy(valueBuffer, 16, value);
}

void PopulateValueBufferInt(char valueBuffer[16], int value)
{
	IntToString(value, valueBuffer, 16);
}

void PopulateValueBufferFloat(char valueBuffer[16], float value)
{
	FloatToString(value, valueBuffer, 16);
}