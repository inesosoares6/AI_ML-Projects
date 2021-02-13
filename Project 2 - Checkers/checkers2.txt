//Ines de Oliveira Soares (256652)

package checkers; // This package is required - don't remove it
public class EvaluatePosition // This class is required - don't remove it
{
	static private final int WIN=Integer.MAX_VALUE/2;
	static private final int LOSE=Integer.MIN_VALUE/2;
	static private boolean _color; // This field is required - don't remove it
	static public void changeColor(boolean color) // This method is required - don't remove it
	{
		_color=color;
	}
	static public boolean getColor() // This method is required - don't remove it
	{
		return _color;
	}

	//This method checks if the piece is in the middle rows
	static public boolean midrow(int size, int i) 
	{
		double row;
		//The number of middle rows will depend if the size is an odd or even number
		if(size%2==1) //If size is an odd number
		{
			row=size/2 - 0.5; //calculates first row of the middle rows
			//if the size is an odd number, the number of middle rows is 1
			if(i==row) return true;
		}
		else // if size is an even number
		{
			row=size/2-1; //calculates first row of the middle rows
			//if the size is an odd number, the number of middle rows is 2
			if(i==row | i==row+1) return true;
		}
		return false;
	}

	//This method checks if the piece is in the miidle box of the board
	static public boolean midbox(int size, int i, int j) 
	{
		double midcolumn;
		//The size of the middle box will depend if the size of the board is an odd or even number
		if(size%2==1) //If size is odd
		{
			midcolumn= size/2 -1.5; //calculates first column of the middle columns
			//if the size is an odd number, the number of middle columns is 3
			if(midrow(size,i)==true & (j==midcolumn | j==midcolumn+1 | j==midcolumn+2)) return true;
		}
		else // if size is even
		{
			midcolumn=size/2-2; //calculates first column of the middle columns
			//if the size is an even number, the number of middle columns is 4
			if(midrow(size,i)==true & (j==midcolumn | j==midcolumn+1 | j==midcolumn+2 | j==midcolumn+3)) return true;
		}
		return false;
	}

	static public int evaluatePosition(AIBoard board) // This method is required and it is the major heuristic method - type your code here
	{
		float myRating=0;
		float opponentsRating=0;
		int size=board.getSize();
		for (int i=0;i<size;i++)
		{
			for (int j=(i+1)%2;j<size;j+=2)
			{
				if (!board._board[i][j].empty) // Found a piece
				{
					if (board._board[i][j].white==getColor()) // This is my piece
					{
					   // If my piece is protected I sum 3 to my rating
						if(
							//My piece is protected if:
								//the piece is on the board's borders
							(i==0 | i==(size-1) | j==0 | j==(size-1)) |
								//the spots behind my piece are occupied
							((!board._board[i-1][j-1].empty) & (!board._board[i-1][j+1].empty)) |
								//the spots in front of my piece are occupied with my pieces
							((board._board[i+1][j-1].white==getColor()) & (board._board[i+1][j+1].white==getColor()))
						) myRating+=3;

					   // If my piece is vulnerable I subtract 3 to my rating
						if(
							//My piece is vulnerable if:
								//the spot behind my piece is empty and the spot ahead is occupied by my opponent's piece
							(board._board[i+1][j-1].white!=getColor() & board._board[i-1][j+1].empty) |
							(board._board[i+1][j+1].white!=getColor() & board._board[i-1][j-1].empty)
						) myRating-=3;

					   // If my piece in the middle rows  I sum 0.5 to my rating
						else if(midrow(size,i)==true) myRating+=0.5;

					   // If my piece in the middle box I sum 2.5 to my rating
						else if(midbox(size,i,j)==true) myRating+=2.5; 

					   // If my piece in the back row I sum 4 to my rating
						if(i==0) myRating+=4;

					   // If my piece is a king I sum 7.75 to my rating
						if (board._board[i][j].king) myRating+=7.75; 

					   // If my regular "pawn" I sum 5 to my rating
						else myRating+=5; 
					}
					else //This is my opponent's piece
					{
					   // If opponent's piece is protected I sum 3 to the opponent's rating
						if(
							//My opponent's piece is protected if:
								//the piece is on the board's borders
							(i==0 | i==(size-1) | j==0 | j==(size-1)) |
								//the spots behind it are occupied
							((!board._board[i+1][j-1].empty) & (!board._board[i+1][j+1].empty)) |
								//the spots in front of the piece are occupied with my opponent's pieces
							(board._board[i-1][j-1].white!=getColor() & board._board[i-1][j+1].white!=getColor())
						) opponentsRating+=3;

					   // If opponent's piece is vulnerable I subtract 3 to the opponent's rating
						if(
							//My opponent's piece is vulnerable if
								//the spot behind the piece is empty abd the spot ahead is occupied by my piece
							(board._board[i-1][j-1].white!=getColor() & board._board[i+1][j+1].empty) |
							(board._board[i-1][j+1].white!=getColor() & board._board[i+1][j-1].empty)
						) opponentsRating-=3;

					   // If opponent's piece in back row  I sum 4 to the opponent's rating
						if(i==size-1) opponentsRating+=4;

					   // If opponent's piece in the middle box I sum 2.5 to the opponent's rating
						else if(midbox(size,i,j)==true) opponentsRating+=2.5;  

					   // If opponent's piece in the middle rows I sum 0.5 to the opponent's rating
						else if(midrow(size,i)==true) opponentsRating+=0.5; 

					   // If opponent's piece is a king I sum 7.75 to the opponent's rating
						if (board._board[i][j].king) opponentsRating+=7.75; 

					   // If opponent's piece is regular "pawn" I sum 5 to the opponent's rating
						else opponentsRating+=5; 
					}
				}
			}
		}
		//Judge.updateLog("Type your message here, you will see it in the log window\n");
		if (myRating==0) return LOSE; 
		else if (opponentsRating==0) return WIN; 
		else return (int)(myRating-opponentsRating);
	}
}
