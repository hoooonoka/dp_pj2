% Author: Zhouhui Wu, zhouhuiw@student.unimelb.edu.au, 963830
% Last Update: 2019.5.23
% Create Date: 2019.5.9
% Purpose: Solve 'Math Puzzle' automatically with Prolog
%          The 'Math Puzzle' here is a game which has a square grid of 
%          squares, each to be filled in with digit 1 to 9 and has to
%          meet following constraints:
%          1. no repeated digits in each row and Columns;
%          2. diagnoal (upper left to lower right) squares have the 
%          same digits;
%          3. heading squares of each row and column stores either
%          the sum or the product of each row.
% Summary: This file consists the source code for a prolog program which 
%          could solve 'Maths Puzzle', the defination for 'Math PUzzle' is
%          defined in 'Purpose' section. 
%          The predicate puzzle_solution/1 would take a puzzle squares
%          as its argument (which is represented as the list of lists)
%          and it would hold if there is a way to fill squares with 
%          digits that meet all constraints, in this case, the solution
%          to the game will be found; otherwise the predicate will not 
%          hold.
%          The idea here is : 
%          First, ensure diagonal squres are filled with the same
%          digit, with predicate diagonal/1;
%          Second, get transposed puzzle with transpose/2, in this case
%          the transposed puzzle's row would be origin puzzle's column,
%          thus columns could be checked with the same predicate with rows;
%          Then, check each row and column with rows/1 predicate, it will 
%          recursively check each square's digit (if the digit >=1 and <=9
%          and if digits in a row are distinct) and check if the heading 
%          square is the sum or product of the row/column.
%          By doing this, the predicate puzzle_solution/1 would successfully
%          find solutions if it holds.

:- use_module(library(clpfd)).



% purpose: ensure the digit in a cell is >= 1 and <= 9
% arguments: argument 1: a cell with a digit
% mode: cell(?X)
cell(X) :-
	X = 1 ; X = 2 ; X = 3 ; X = 4 ; X = 5 ; X = 6 ; X = 7 ; X = 8 ; X = 9.


% purpose: ensure the diagonal elements are the same
% arguments: argument 1: rows in the puzzle, represented as a list of lists
% comment: find the diagonal element use nth0/3 and use predicate 
%          diagonal_kernel/3 to check if diagonal elements in other rows are
%          same with diagonal element in this row
% mode: diagonal(+X)
diagonal([Row|Rows]) :-
	nth0(1, Row, Element),
	diagonal_kernel(Rows,Element,2).


% purpose: check if diagonal elements are the same
% arguments: argument 1: rows, represented as a list of lists
%            argument 2: the diagnoal element
%            argument 3: the diagnoal element's Index
% comment: recursively check if each row's diagnoal element is same
%          first use nth0/3 to check if the diagnoal element in this row
%          equals to the diagnoal element in last row
%          then compute the index for the diagnoal element in the next row,
%          and recursively check if it equals the diagnoal element in last row
% mode: diagonal_kernel(+Rows,?Element,+Index)
diagonal_kernel([],_,_).
diagonal_kernel([Row|Rows],Element,Index) :-
	nth0(Index,Row,Element),
	NextIndex is Index + 1,
	diagonal_kernel(Rows,Element,NextIndex).


% purpose: check if a row meets the row constraints
% arguments: argument 1: the heading cell in the row
%            argument 2: the rest cells in the row, represented as a list
% comment: first use distinct_digits/1 check if all digits in a row are
%          different; then check if the heading element is sum or product
%          of the rest elements, use sum_list/2 to check if it is the sum
%          use product_list/2 to check if it is the product
% mode: row(+Total,+Row)
row(Total,Row) :-
	distinct_digits(Row),
	(sum_list(Row,Total) ; product_list(Total,Row)).


% purpose: check all rows meet the row constraints
% arguments: argument 1: rows in puzzle, represented as a list of lists
% comment: recursively check each row if it meets row constraints
%          for each row, first check all its cells if they >=1 and <=9
%          with the all_cells/1 predicate, then use row/2 to check if 
%          all elements in the row are different and if the heading element
%          equals the sum or the product of the rest elements
% mode: all_rows(+Rows)
all_rows([]).
all_rows([[Total|Cells]|Rows]) :-
	all_cells(Cells),
	row(Total,Cells),
	all_rows(Rows).


% purpose: check if the heading element equals to the product of rest elements
% arguments: argument 1: the heading element
%            argument 2: the rest elements in the row, represented as a list
% comment: recursively check if the first element equals the product of rest
%          elements. follow the same naming style with sum_list/2
% mode: product_list(+Total,+Cells)
product_list(Cell,[Cell]).
product_list(Total,[Cell|Cells]) :-
	Difference is Total / Cell,
	product_list(Difference,Cells).


% purpose: check if meet digits are different
% arguments: argument 1: a row represented as a list
% comment: first, get a non-duplicated sorted list using sort/2, as the sort/2
%          will remove duplicated items from the origin list;
%          then check if two lists have the same length with same_length/2
%          if they have the same length, digits in origin list are different,
%          otherwise, the origin list contains same digits.
% mode: distinct_digits(+Row)
distinct_digits(Row) :-
	sort(Row, NonDuplicatedRow),
	same_length(Row,NonDuplicatedRow).


% purpose: the solution predicate, which find solution for a puzzle
% arguments: argument 1: puzzle represented as a list of lists
% comment: the solution finding is done by:
%          First, check if diagonal elements are the same, using 
%          diagonal/1 predicate
%          Second, get a transposed puzzle use transpose/2, in this case, 
%          rows and columns could be checked with the same predicate
%          Then, check each rows and columns with predicate all_rows/1,
%          which holds if all rows meet constraints. As rows in transposed
%          is the same with the columns in origin puzzle, check the transposed
%          puzzle's rows is similar to check origin puzzle's columns
% mode: puzzle_solution(+Puzzle)
puzzle_solution([Row|Rows]) :-
	diagonal(Rows),
	transpose([Row|Rows],[_|Columns]),
	all_rows(Rows),
	all_rows(Columns).


% purpose: check a row if all cells have a digit >=1 and <=9
% arguments: a row in the puzzle, represented as a list
% comment: recursively check each cell in a row if its value >=1 and <=9
%          cell/1 predicate holds if a digit >=1 and <=9
% mode: all_cells(+Row)
all_cells([]).
all_cells([Cell|Cells]) :-
	cell(Cell),
	all_cells(Cells).
