
local tb    = {
    wd_pg1 = --武当剑法--普攻1式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,60},{20,80},{30,120},{32,128}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,300*0.95},{32,330*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,300*1.05},{32,330*1.05}}
			},
		state_npchurt_attack={100,7},

    }, 
    wd_pg2 = --武当剑法--普攻2式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,60},{20,80},{30,120},{32,128}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,300*0.95},{32,330*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,300*1.05},{32,330*1.05}}
			},
		state_npchurt_attack={100,7},

    }, 
	
    wd_pg3 = --武当剑法--普攻3式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,65},{20,85},{30,130},{32,140}}},
		attack_earthdamage_v={
			[1]={{1,60*1},{20,200*0.95},{30,350*0.95},{32,380*0.95}},
			[3]={{1,60*1},{20,200*1.05},{30,350*1.05},{32,380*1.05}}
			},
	--	state_stun_attack={{{1,80},{20,80}},{{1,6},{20,6}}},
		state_npchurt_attack={100,7},

	
    }, 	
    wd_pg4 = --武当剑法--普攻4式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,100},{20,150},{30,200},{32,210}}},
		attack_earthdamage_v={
			[1]={{1,100*1},{20,350*0.95},{30,500*0.95},{32,530*0.95}},
			[3]={{1,100*1},{20,350*1.05},{30,500*1.05},{32,530*1.05}}
			},
		state_stun_attack={{{1,80},{20,80},{30,80},{32,80}},{{1,6},{20,6},{30,6},{32,6}}},
		state_npcknock_attack={100,12,20},
		spe_knock_param={9 , 4, 26},
    }, 
    wd_jfjt = --剑飞惊天-1级主动1--10级
    { 
		userdesc_000={610},			
    }, 
    wd_jfjt_child = --剑飞惊天_子--10级
    { 
		attack_usebasedamage_p={{{1,240},{15,300},{16,304},{21,324}}},
		attack_earthdamage_v={
			[1]={{1,200*1},{15,500*0.95},{16,520*0.95},{21,620*0.95}},
			[3]={{1,200*1},{15,500*1.05},{16,520*1.05},{21,620*1.05}}
			},
		state_stun_attack={{{1,100},{15,100},{16,100},{21,100}},{{1,15*1},{15,15*1},{16,15*1},{21,15*1}}},
		state_npcknock_attack={100,15,20},
		spe_knock_param={9 , 4, 26},
		missile_hitcount={{{1,6},{15,6},{16,6},{21,6}}},		
    }, 
    wd_tdwj = --天地无极-4级主动2--15级
    { 
		attack_usebasedamage_p={{{1,150},{15,200},{16,205},{21,230}}},
		attack_earthdamage_v={
			[1]={{1,600*1},{15,800*0.95},{16,814*0.95},{21,884*0.95}},
			[3]={{1,600*1},{15,800*1.05},{16,814*1.05},{21,884*1.05}}
			},
		state_stun_attack={{{1,30},{15,30},{16,30},{21,30}},{{1,15*1},{15,15*1},{16,15*1},{21,15*1}}},
		state_npcknock_attack={100,12,30},
		spe_knock_param={9 , 4, 26},
		skill_mintimepercast_v={{{1,30*15},{15,25*15},{16,25*15},{21,25*15}}},
		missile_hitcount={{{1,6},{15,6}}},
    },     
	wd_zwww = --坐忘无我-10级主动3--15级
    { 
		magicshield={{{1,5*100},{15,20*100},{16,21*100},{21,26*100}},{{1,15*20},{15,15*20},{16,15*20},{21,15*20}}},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100
		skill_statetime={{{1,15*20},{15,15*20},{16,15*20},{21,15*20}}},
		skill_mintimepercast_v={{{1,40*15},{15,30*15},{16,30*15},{21,30*15}}},		
    },
    wd_mzhy = --迷踪幻影-20级被动1--10级
    {
		physics_potentialdamage_p={{{1,20},{10,50},{11,53}}},
		runspeed_v={{{1,20},{10,50},{11,53}}},
		state_slowall_resistrate={{{1,40},{10,100},{11,106}}},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
	wd_rjhy = --人剑合一-30级主动4--15级
    { 
		userdesc_000={612},	
		skill_mintimepercast_v={{{1,40*15},{15,30*15},{16,30*15},{21,30*15}}},
    }, 
	wd_rjhy_child = --人剑合一-30级主动4--15级
    { 
		attack_usebasedamage_p={{{1,180},{15,300},{16,308},{21,348}}},
		attack_earthdamage_v={
			[1]={{1,800*1},{15,1200*1},{16,1226*1},{21,1356*1}},
			[3]={{1,800*1},{15,1200*1},{16,1226*1},{21,1356*1}}
			},
		state_stun_attack={{{1,100},{15,100},{16,100},{21,100}},{{1,15*1},{15,15*1},{16,15*1},{21,15*1}}},
		adddamagebydist={{{1,100},{15,100},{16,100},{21,100}},200000,100},					--放大%=(min(（距离-参数3）*参数1，参数2)/1000)%
		addstuntime_bydist={{{1,100},{15,100},{16,100},{21,100}},200000,100},				--放大%=(min(（距离-参数3）*参数1，参数2)/1000)%
		missile_hitcount={{{1,4},{15,4},{16,4},{21,4}}},
		
    },
    wd_zwqj = --真武七截-40级被动2（光环）--10级
    { 
		physics_potentialdamage_p={{{1,30},{10,70},{11,74}}},
		userdesc_106={{{1,15},{10,30},{11,32}}},					--增加队友攻击力的描述
		skill_statetime={{{1,15*3},{10,15*3},{11,15*3}}},
    },	
    wd_zwqj_team = --真武七截_队友--10级
    { 
		physics_potentialdamage_p={{{1,15},{10,30},{11,32}}},
		skill_statetime={{{1,15*3},{10,15*3},{11,15*3}}},
    },	
    wd_gjjf = --高级剑法-50级被动3--10级
    {
		add_skill_level={601,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={602,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={603,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={604,{{1,1},{10,10},{11,11}},0},
		userdesc_000={620},	
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    wd_gjjf_child = --高级剑法_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
    { 
		attack_usebasedamage_p={{{1,3},{10,30},{11,34}}},
		attack_earthdamage_v={
			[1]={{1,12},{10,120},{11,135}},
			[3]={{1,12},{10,120},{11,135}}
			},
    }, 
    wd_tyzq = --太一真气-60级被动4--10级
    { 
		autoskill={61,{{1,1},{10,10},{11,11}}},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
		userdesc_000={618},	
    },
    wd_tyzq_child = --太一真气_子--10级
    { 
		ignore_series_state={},	
		userdesc_101={{{1,15*30},{10,15*20},{11,15*19}}}, 			--假的魔法属性，仅用作描述，此时间需对应autoskill表中的“触发间隔时间”
		--ignore_abnor_state={},	
		skill_statetime={{{1,15*3},{10,15*6},{11,15*6}}},
    },
    wd_xtxf = --玄天心法-70级被动5--10级
    { 
		autoskill={64,{{1,1},{10,10},{11,11}}},
		userdesc_101={{{1,40},{10,90},{11,95}}},			--描述用，实际触发几率请查看autoskill.tab中的玄天心法
		userdesc_102={{{1,15*20},{10,15*20},{11,15*20}}},	--描述用，实际触发几率请查看autoskill.tab中的玄天心法
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    wd_tjwy = --太极无意-80级被动6--20级
    {
		physics_potentialdamage_p={{{1,15},{20,35},{21,36}}},
		lifemax_p={{{1,5},{20,25},{21,26}}},
		attackspeed_v={{{1,5},{20,20},{21,21}}},
		state_stun_attackrate={{{1,80},{20,200},{21,206}}},
		skill_statetime={{{1,-1},{20,-1},{21,-1}}},
    },
    wd_90_qxj = --七星诀-90级被动7--10级
    {
		all_series_resist_p={{{1,20},{10,50},{11,55}}},	
		recover_life_v={{{1,300},{10,600},{11,700}},15*5},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},		
    },
    wd_wjftj = --万剑封天诀-怒气--10级
    { 
		attack_usebasedamage_p={{{1,1000},{30,800}}},
		attack_earthdamage_v={
			[1]={{1,300*0.9},{30,200*0.9},{31,200*0.9}},
			[3]={{1,300*1.1},{30,200*1.1},{31,200*1.1}}
			},		
    },
    wd_wjftj_child = --万剑封天诀_子
    { 
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,37},{30,37}}},
    },	
}

FightSkill:AddMagicData(tb)