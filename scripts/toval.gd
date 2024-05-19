@tool
extends Node

func linear(cur:float,goal:float,change:float):
	return clamp(goal,cur-change,cur+change)-cur

func mul(cur:float,goal:float,change:float):
	return cur-((cur-goal)/change)-cur

func lin_to_mul(cur:float,goal:float,lchange:float,echange:float):
	if ((abs(goal-cur)>(lchange*echange)) or (mul(cur,goal,echange)>lchange)): return linear(cur,goal,lchange)
	else: return mul(cur,goal,echange)
