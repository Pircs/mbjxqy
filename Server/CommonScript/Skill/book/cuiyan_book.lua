
local tb    = {
    book_cy_forxjlw = --璇玑罗舞
    { 
		addms_life1={807,{{1,12*1},{4,12*1},{5,12*2},{9,12*2},{10,12*3}}},		--增加璇玑罗舞子弹的存活时间（目前每12帧伤害一次）
		userdesc_101={807,{{1,1},{4,1},{5,2},{9,2},{10,3}}},					--描述用：璇玑罗舞增加的攻击次数
		add_slowall_r={807,{{1,20},{10,40}}},				 					--增加璇玑罗舞造成迟缓的几率
		userdesc_102={807,{{1,20},{10,40}}},									--描述用：增加璇玑罗舞造成迟缓的几率
		add_slowall_t={807,{{1,15*1},{10,15*1.5}}},				 			--增加璇玑罗舞造成迟缓的时间
		userdesc_103={807,{{1,15*1},{10,15*1.5}}},							--描述用：增加璇玑罗舞造成迟缓的时间
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_forydlh = --雨打梨花
    { 
		add_usebasedmg_p1={829,{{1,2},{10,10}}},						--增加雨打梨花第一段攻击力	
		add_usebasedmg_p2={830,{{1,2},{10,10}}},						--增加雨打梨花第二段攻击力	
		add_usebasedmg_p3={831,{{1,2},{10,10}}},						--增加雨打梨花第三段攻击力	
		userdesc_101={829,{{1,2},{10,10}}},								--描述用：增加雨打梨花攻击力
		add_igdefense_p1={829,{{1,50},{10,200}}},  						--增加第一段忽闪%
		add_igdefense_p2={830,{{1,50},{10,200}}},  						--增加第二段忽闪%
		add_igdefense_p3={831,{{1,50},{10,200}}},  						--增加第三段忽闪%
		userdesc_102={829,{{1,50},{10,200}}},  							--描述用：增加忽闪%
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_forzh = --召唤啵啵
    { 
		addcall_npclife={811,{{1,10},{10,30}}},					--增加熊猫血量
		userdesc_101={811,{{1,10},{10,30}}},					--描述用：增加熊猫血量
		addcall_npcdmg={811,{{1,10},{10,30}}},					--增加熊猫攻击
		userdesc_102={811,{{1,10},{10,30}}},					--描述用：增加熊猫攻击
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_forbzwy = --冰踪无影
    { 
		addms_dmg_range1={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5}}},									--增加子弹爆炸范围格子，1格子=0.28米直径
		userdesc_101={817,{{1,1*30},{2,1*30},{3,2*30},{4,2*30},{5,3*30},{6,3*30},{7,4*30},{8,4*30},{9,5*30},{10,5*30}}},		--描述用：增加冰踪无影爆炸范围，对外描述每两级增加0.3米
		addms_hitplayer_c1={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5}}},								--增加命中个数
		userdesc_102={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5}}},										--描述用：命中个数
		addstartskill={817,870,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_mid_forxjlw = --中级璇玑罗舞
    { 
		add_usebasedmg_p1={806,{{1,0},{10,0},{11,20},{15,70}}},							--增加璇玑罗舞飞行时攻击力	
		add_usebasedmg_p2={807,{{1,0},{10,0},{11,20},{15,70}}},							--增加璇玑罗舞定点时攻击力		
		userdesc_104={807,{{1,0},{10,0},{11,10},{15,50}}},								--描述用：增加璇玑罗舞攻击力	
		addms_life1={807,{{1,12*1},{4,12*1},{5,12*2},{9,12*2},{10,12*3},{15,12*4}}},	--增加璇玑罗舞子弹的存活时间（目前每12帧伤害一次）
		userdesc_101={807,{{1,1},{4,1},{5,2},{9,2},{10,3},{15,4}}},						--描述用：璇玑罗舞增加的攻击次数
		add_slowall_r={807,{{1,20},{10,40},{15,60}}},									--增加璇玑罗舞造成迟缓的几率
		userdesc_102={807,{{1,20},{10,40},{15,60}}},									--描述用：增加璇玑罗舞造成迟缓的几率
		add_slowall_t={807,{{1,15*1},{10,15*1.5},{15,15*1.5}}},				 		--增加璇玑罗舞造成迟缓的时间
		userdesc_103={807,{{1,15*1},{10,15*1.5},{15,15*1.5}}},						--描述用：增加璇玑罗舞造成迟缓的时间
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_mid_forydlh = --中级雨打梨花
    { 
		deccdtime={808,{{1,0},{10,0},{11,15*1},{15,15*5}}},						--减少雨打梨花CD时间
		add_usebasedmg_p1={829,{{1,2},{10,15},{15,30}}},						--增加雨打梨花第一段攻击力	
		add_usebasedmg_p2={830,{{1,2},{10,15},{15,30}}},						--增加雨打梨花第二段攻击力	
		add_usebasedmg_p3={831,{{1,2},{10,15},{15,30}}},						--增加雨打梨花第三段攻击力	
		userdesc_101={829,{{1,2},{10,10},{15,15}}},								--描述用：增加雨打梨花攻击力
		add_igdefense_p1={829,{{1,50},{10,200},{15,260}}},  					--增加第一段忽闪%
		add_igdefense_p2={830,{{1,50},{10,200},{15,260}}},  					--增加第二段忽闪%
		add_igdefense_p3={831,{{1,50},{10,200},{15,260}}},  					--增加第三段忽闪%
		userdesc_102={829,{{1,50},{10,200},{15,260}}},							--描述用：增加雨打梨花忽闪%
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_mid_forzh = --中级召唤啵啵
    { 
		deccdtime={810,{{1,0},{10,0},{11,15*1},{15,15*5}}},				--减少召唤熊猫CD时间
		addcall_npclife={811,{{1,10},{10,30},{15,40}}},					--增加熊猫血量
		userdesc_101={811,{{1,10},{10,30},{15,40}}},					--描述用：增加熊猫血量
		addcall_npcdmg={811,{{1,10},{10,30},{15,40}}},					--增加熊猫攻击
		userdesc_102={811,{{1,10},{10,30},{15,40}}},					--描述用：增加熊猫攻击
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_mid_forbzwy = --中级冰踪无影
    { 
		autoskill={83,{{1,1},{10,10},{15,15}}},		
		addms_dmg_range1={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5},{15,6}}},									--增加子弹爆炸范围格子，1格子=0.28米直径
		userdesc_101={817,{{1,1*30},{2,1*30},{3,2*30},{4,2*30},{5,3*30},{6,3*30},{7,4*30},{8,4*30},{9,5*30},{10,5*30},{15,6*30}}},		--描述用：增加冰踪无影爆炸范围，对外描述每两级增加0.3米
		addms_hitplayer_c1={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5},{15,6}}},									--增加命中个数
		userdesc_102={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5},{15,6}}},										--描述用：命中个数
		userdesc_000={869},
		addstartskill={817,870,{{1,1},{10,10},{15,15}}},
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_mid_forbzwy_child = --中级冰踪无影_子
    { 
		attack_usebasedamage_p={{{1,0},{10,0},{11,100},{15,200}}},
		attack_waterdamage_v={
			[1]={{1,0},{10,0},{11,300*0.9},{15,600*0.9}},
			[3]={{1,0},{10,0},{11,300*1.1},{15,600*1.1}}
			},
		missile_hitcount={{{1,3},{15,3}}},
    },
    book_cy_high_forxjlw = --高级璇玑罗舞
    { 
		add_usebasedmg_p1={806,{{1,0},{10,0},{11,20},{15,70},{20,85}}},							--增加璇玑罗舞飞行时攻击力	
		add_usebasedmg_p2={807,{{1,0},{10,0},{11,20},{15,70},{20,85}}},							--增加璇玑罗舞定点时攻击力		
		addms_life1={807,{{1,12*1},{4,12*1},{5,12*2},{9,12*2},{10,12*3},{15,12*4},{19,12*4},{20,12*5}}},	--增加璇玑罗舞子弹的存活时间（目前每12帧伤害一次）
		userdesc_101={807,{{1,1},{4,1},{5,2},{9,2},{10,3},{15,4},{19,4},{20,5}}},						--描述用：璇玑罗舞增加的攻击次数
		add_slowall_r={807,{{1,20},{10,40},{15,60},{20,70}}},									--增加璇玑罗舞造成迟缓的几率
		add_slowall_t={807,{{1,15*1},{10,15*1.5},{15,15*1.5},{20,15*2}}},				 				--增加璇玑罗舞造成迟缓的时间
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_high_forydlh = --高级雨打梨花
    { 
		deccdtime={808,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*6}}},					--减少雨打梨花CD时间
		add_usebasedmg_p1={829,{{1,2},{10,15},{15,30},{20,40}}},						--增加雨打梨花第一段攻击力	
		add_usebasedmg_p2={830,{{1,2},{10,15},{15,30},{20,40}}},						--增加雨打梨花第二段攻击力	
		add_usebasedmg_p3={831,{{1,2},{10,15},{15,30},{20,40}}},						--增加雨打梨花第三段攻击力	
		add_igdefense_p1={829,{{1,50},{10,200},{15,260},{20,300}}},  					--增加第一段忽闪%
		add_igdefense_p2={830,{{1,50},{10,200},{15,260},{20,300}}},  					--增加第二段忽闪%
		add_igdefense_p3={831,{{1,50},{10,200},{15,260},{20,300}}},  					--增加第三段忽闪%
		add_slowall_t={829,{{1,0},{15,0},{16,15*0.2},{20,15*1.5}}},				 		--增加雨打梨花造成迟缓的时间
		skill_statetime={{{1,-1},{10,-1},{15,-1},{20,-1}}},	
    },
    book_cy_high_forzh = --高级召唤啵啵
    { 
		deccdtime={810,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*6}}},			--减少召唤熊猫CD时间
		addcall_npclife={811,{{1,10},{10,30},{15,40},{20,50}}},					--增加熊猫血量
		addcall_npcdmg={811,{{1,10},{10,30},{15,40},{20,50}}},					--增加熊猫攻击
		add_callnpc_skill={810,877,{{1,1},{15,15},{20,20}}},					--召唤熊猫的buffid,给熊猫的buffid,等级
		userdesc_000={877},
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_high_forzh_child = --高级召唤啵啵_子
    { 
		add_usebasedmg_p1={834,{{1,0},{15,0},{16,20},{20,50}}},					--增加熊猫撞击的攻击力
		add_slowall_t={834,{{1,0},{15,0},{16,15*0.2},{20,15*1}}},				--增加熊猫撞击造成迟缓的时间
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_high_forbzwy = --高级冰踪无影
    { 
		autoskill={86,{{1,1},{10,10},{15,15}}},		
		addms_dmg_range1={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5},{15,6},{20,8}}},									--增加子弹爆炸范围格子，1格子=0.28米直径
		userdesc_101={817,{{1,1*30},{2,1*30},{3,2*30},{4,2*30},{5,3*30},{6,3*30},{7,4*30},{8,4*30},{9,5*30},{10,5*30},{15,6*30},{20,8*30}}},		--描述用：增加冰踪无影爆炸范围，对外描述每两级增加0.3米
		addms_hitplayer_c1={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5},{15,6},{20,6}}},									--增加命中个数
		userdesc_102={817,{{1,1},{2,1},{3,2},{4,2},{5,3},{6,3},{7,4},{8,4},{9,5},{10,5},{15,6},{20,6}}},										--描述用：命中个数
		userdesc_000={879},
		addstartskill={817,870,{{1,1},{10,10},{15,15},{20,20}}},
		add_usebasedmg_p1={817,{{1,0},{15,0},{16,5},{20,20}}},						--增加冰踪无影攻击力	
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_cy_high_forbzwy_child = --高级冰踪无影_子
    { 
		attack_usebasedamage_p={{{1,0},{10,0},{11,100},{15,200},{20,260}}},
		attack_waterdamage_v={
			[1]={{1,0},{10,0},{11,300*0.9},{15,600*0.9},{20,800*0.9}},
			[3]={{1,0},{10,0},{11,300*1.1},{15,600*1.1},{20,800*1.1}}
			},
		missile_hitcount={{{1,3},{15,3}}},
    },
}

FightSkill:AddMagicData(tb)