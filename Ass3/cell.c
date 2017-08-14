extern int WorldWidth;
extern int WorldLength;
extern char state[10000]; 

int kLivingNeighbors(int k, int x, int y);

char cell(int x, int y){
			int place = x*(WorldWidth+1) + y;
			char liveness='0';
			if (state[place]=='0') /* If the cell is dead, should become alive under this terms */
				if (kLivingNeighbors(3,x,y)==1)
				{ 	
					liveness='1';
				}

			if (state[place]!='0') /* If the cell is alive, should stay alive under this terms */
				if ((kLivingNeighbors(3,x,y)==1) || (kLivingNeighbors(2,x,y)==1)){
					if (state[place]<'9') {
					liveness=state[place]+1; /* If he's 7 so he will become 8 */
					}
						else {
							liveness=state[place];
							} 
				}
			 
		    return liveness;
}

int kLivingNeighbors(int k, int x, int y){
	int sum=0;
	int tmp;
	if (x==0)
		tmp = (WorldLength-1)*(WorldWidth+1)+y;
	else 
		tmp = ((x-1)%WorldLength)*(WorldWidth+1)+y;
	int up=state[tmp];

	tmp = ((x+1)%WorldLength)*(WorldWidth+1)+y;
	int down=state[tmp];
	
	if (y==0)
		tmp = x*(WorldWidth+1)+(WorldWidth-1);
	else 
		tmp = x*(WorldWidth+1)+(y-1);
	int left=state[tmp];

	if (y==(WorldWidth-1))
		tmp = x*(WorldWidth+1)+0;
	else 
		tmp = x*(WorldWidth+1)+(y+1);
	int right=state[tmp];

	if (y==(WorldWidth-1))
	{	
		if (x==0)
			tmp = (WorldLength-1)*(WorldWidth+1)+0;
		else 
			tmp = ((x-1)%WorldLength)*(WorldWidth+1)+0;
	}
	else {
		if (x==0)
			tmp = ((WorldLength-1)*(WorldWidth+1))+(y+1);
		else
			tmp = ((x-1)%WorldLength)*(WorldWidth+1)+(y+1);
	}
	int upRight=state[tmp];

	if (y==0){
		if (x==0)
			tmp = (WorldLength-1)*(WorldWidth+1)+(WorldWidth-1);
		else 
			tmp = ((x-1)%WorldLength)*(WorldWidth+1)+(WorldWidth-1);
	}
	else {
		if (x==0)
			tmp = (WorldLength-1)*(WorldWidth+1)+(y-1);
		else 
			tmp = ((x-1)%WorldLength)*(WorldWidth+1)+(y-1);
	}
	int upLeft=state[tmp];

	if (y==(WorldWidth-1))
		tmp = ((x+1)%WorldLength)*(WorldWidth+1)+0;
	else 
		tmp = ((x+1)%WorldLength)*(WorldWidth+1)+(y+1);
	int downRight=state[tmp];

	if (y==0)
		tmp = ((x+1)%WorldLength)*(WorldWidth+1)+(WorldWidth-1);
	else 
		tmp = ((x+1)%WorldLength)*(WorldWidth+1)+(y-1);
	int downLeft=state[tmp];

	if(up>='1'&&up<='9')
		sum++;
	if(down>='1'&&down<='9')
		sum++;
	if(right>='1'&&right<='9')
		sum++;
	if(left>='1'&&left<='9')
		sum++;
	if(upLeft>='1'&&upLeft<='9')
		sum++;
	if(upRight>='1'&&upRight<='9')
		sum++;
	if(downLeft>='1'&&downLeft<='9')
		sum++;
	if(downRight>='1'&&downRight<='9')
		sum++;

	if (sum==k) return 1; 
		else return 0;
}