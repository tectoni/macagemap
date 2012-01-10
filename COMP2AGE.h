/***********/
/* Defines */
/***********/
#define kMaxLineLength		200
#define kZeroByte			0

/***********************/
/* Global Definitions */
/***********************/
struct fileData	*gFirstPtr, *gLastPtr;

FILE			*ifp, *ofp;
 char gInputFileName[32] , gOutputFileName[32]; /*Macintosh File System erlaubt nur 32 Zeichen pro File */


/***********************/
/* Struct Declarations */
/***********************/
struct fileData
{
	char			dataLine[ kMaxLineLength + 1 ];

/*	char			convLine[ kMaxLineLength + 1 ];  
wird bei comberror nicht verwendet */

	struct 			fileData	*next;
};

/*struct unk  
{
float		L_l, L_u, I_l, I_u, I_pk, t_bg, t_pk;
int			no;
};
*/

/********************************/
/* Function Prototypes - main.c */
/********************************/
void 			InitVars( void );
void 			ConvertData( void );
void			AddToList( struct fileData *curPtr );
int 			ReadMoreFiles( void );
char			*MallocAndCopy( char *line );
void			HandleInputFile( void );
char			ReadStructFromFile( FILE *fp, struct fileData *infoPtr );
double			ApaAge( double, double, double);
double			CalcThStar( double, double, double);
void			Flush( void );