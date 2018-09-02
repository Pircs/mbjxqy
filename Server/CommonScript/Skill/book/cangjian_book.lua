
local tb    = {
    book_cj_jxmy = --九溪弥烟
    {
		add_igdefense_v1={4406,{{1,50},{10,100}}},  		--增加忽闪
		add_attackrating_v1={4406,{{1,50},{10,300}}},		--增加命中值
		skill_statetime={{{1,-1},{10,-1}}},
    },
     book_cj_mid_jxmy = --九溪弥烟--中级
    {
		add_igdefense_v1={4406,{{1,50},{10,100},{11,120},{15,200}}},  		--增加忽闪
		add_attackrating_v1={4406,{{1,50},{10,300},{11,320},{15,400}}},		--增加命中值
		add_usebasedmg_p1={4406,{{1,0},{10,0},{11,5},{15,25}}},				--增加攻击力
		skill_statetime={{{1,-1},{10,-1}}},
    },
     book_cj_high_jxmy = --九溪弥烟--高级
    {
		add_igdefense_v1={4406,{{1,50},{10,100},{11,120},{15,200},{20,240}}},  		--增加忽闪
		add_attackrating_v1={4406,{{1,50},{10,300},{11,320},{15,400},{20,400}}},	--增加命中值
		add_usebasedmg_p1={4406,{{1,0},{10,0},{11,5},{15,25},{20,50}}},				--增加攻击力
		add_fixed_t={4406,{{1,0},{15,0},{16,15*0.2},{20,15*1}}},					--增加造成定身的时间
		add_fixed_r={4406,{{1,0},{15,0},{16,10},{20,50}}},							--增加造成定身的概率
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_xj = --心剑
    {
		addstartskill={4436,4443,{{1,1},{10,10}}},  
		userdesc_000={4443},				
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_xj_child = --心剑_子
    {
		deadlystrike_v={{{1,50},{10,200}}},				--增加会心值
		skill_statetime={{{1,15*15},{10,15*15}}},		--需要跟主技能[心剑]时间一致
    },
    book_cj_mid_xj = --心剑--中级
    {
		addstartskill={4436,4449,{{1,1},{10,10},{15,15}}},
		userdesc_000={4449},
		add_state_time1={4410,{{1,0},{10,0},{11,15*1},{15,15*5}}},  		--增加心剑BUFF持续时间
		add_state_time2={4423,{{1,0},{10,0},{11,15*1},{15,15*5}}},  		--增加映波锁澜BUFF1持续时间
		add_state_time3={4431,{{1,0},{10,0},{11,15*1},{15,15*5}}},  		--增加映波锁澜BUFF2持续时间
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_mid_xj_child = --心剑_子--中级
    {
		deadlystrike_v={{{1,50},{10,200},{15,250}}},			--增加会心值
		skill_statetime={{{1,15*15},{10,15*15},{15,15*20}}},	--需要跟主技能[心剑]时间一致
    },
    book_cj_high_xj = --心剑--高级
    {
		addstartskill={4436,4456,{{1,1},{10,10},{15,15}}},
		userdesc_000={4456},
		add_state_time1={4410,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*5}}},  		--增加BUFF持续时间
		add_state_time2={4423,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*5}}},  		--增加映波锁澜BUFF1持续时间
		add_state_time3={4431,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*5}}},  		--增加映波锁澜BUFF2持续时间
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_high_xj_child = --心剑_子--高级
    {
		deadlystrike_v={{{1,50},{10,200},{15,250},{20,250}}},				--增加会心值
		attackspeed_v={{{1,0},{15,0},{16,5},{20,25}}},						--增加攻击速度
		skill_statetime={{{1,15*15},{10,15*15},{15,15*20},{20,15*20}}},		--需要跟主技能[心剑]时间一致
    },
     book_cj_phdy = --平湖断月
    {
		add_fixed_t={4409,{{1,15*0.5},{10,15*1}}},					--增加造成定身的时间
		add_fixed_r={4409,{{1,30},{10,50}}},						--增加造成定身的概率
		skill_statetime={{{1,-1},{10,-1}}},
    },
     book_cj_mid_phdy = --平湖断月--中级
    {
		add_fixed_t={4409,{{1,15*0.5},{10,15*1},{15,15*1.5}}},				--增加造成定身的时间
		add_fixed_r={4409,{{1,30},{10,50},{15,60}}},						--增加造成定身的概率
		add_hitskill1={4409,4451,{{1,1},{10,10},{15,15}}},
		userdesc_000={4451},							
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_mid_phdy_child = --平湖断月_子--中级
    {
		runspeed_p={{{1,-0},{10,-0},{11,-2},{15,-20}}},			--减少基础移速%（角色出生基础移速是270，暂时没有其他途径增加基础移速）
		skill_statetime={{{1,15*2},{10,15*2},{11,15*2},{15,15*5}}},
    },
     book_cj_high_phdy = --平湖断月--高级
    {
		add_fixed_t={4409,{{1,15*0.5},{10,15*1},{15,15*1.5},{20,15*1.5}}},				--增加造成定身的时间
		add_fixed_r={4409,{{1,30},{10,50},{15,60},{20,70}}},						--增加造成定身的概率
		add_hitskill1={4409,4458,{{1,1},{10,10},{20,20}}},	
		autoskill={134,{{1,1},{10,10},{15,15},{20,20}}},
		userdesc_000={4458},
		userdesc_101={{{1,0},{15,0},{16,10},{20,50}}},		--免疫状态描述用，实际触发几率查看auto.tab中的高级·平湖断月					
		userdesc_102={{{1,0},{15,0},{16,15*1},{20,15*3}}},	--免疫状态描述用，实际持续时间查看book_cj_high_phdy_child2		
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_high_phdy_child1 = --平湖断月_子1--高级
    {
		runspeed_p={{{1,-0},{10,-0},{11,-2},{15,-20},{20,-30}}},			--减少基础移速%（角色出生基础移速是270，暂时没有其他途径增加基础移速）
		skill_statetime={{{1,15*2},{10,15*2},{11,15*2},{15,15*5},{20,15*5}}},
    },
    book_cj_high_phdy_child2 = --平湖断月_子2--高级
    {
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,0},{15,0},{16,15*1},{20,15*3}}},
    },
    book_cj_fcyj = --峰插云景
    {
		addstartskill={4416,4446,{{1,1},{10,10}}},  
		userdesc_000={4446},		
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_fcyj_child = --峰插云景_子
    {
		recover_life_v={{{1,300},{10,600}},15},	
		skill_statetime={{{1,2},{10,2}}},
    },
    book_cj_mid_fcyj = --峰插云景--中级
    {
		addstartskill={4416,4453,{{1,1},{10,10},{15,15}}},  
		deccdtime={4413,{{1,0},{10,0},{11,15*1},{15,15*5}}},
		userdesc_000={4453},						
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_cj_mid_fcyj_child = --峰插云景_子--中级
    {
		recover_life_v={{{1,300},{10,600},{15,600}},15},	
		skill_statetime={{{1,2},{10,2},{15,2}}},
    },
    book_cj_high_fcyj = --峰插云景--高级
    {
		addstartskill={4416,4461,{{1,1},{10,10},{20,20}}},
		add_hitskill1={4414,4462,{{1,1},{10,10},{20,20}}},  
		deccdtime={4413,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*5}}},	
		userdesc_000={4461,4462},			
		skill_statetime={{{1,-1},{20,-1}}},
    },
    book_cj_high_fcyj_child1 = --峰插云景_子1--高级
    {
		recover_life_v={{{1,300},{10,600},{15,600},{20,600}},15},	
		skill_statetime={{{1,2},{10,2},{15,2},{20,2}}},
    },
    book_cj_high_fcyj_child2 = --峰插云景_子2--高级
    {
		all_series_resist_p={{{1,0},{15,0},{16,-10},{20,-50}}},	
		superposemagic={{{1,4},{10,4},{11,4},{20,4}}},						--叠加层数		
		skill_statetime={{{1,0},{15,0},{16,15*2},{20,15*3}}},
    },
}

FightSkill:AddMagicData(tb)