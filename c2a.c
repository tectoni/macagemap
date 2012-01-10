#include "c2a.h"

/*
Old stuff for C prog, not needed for Cocoa


main( void )
{
    FILE *thfp, *ufp, *pbfp, *agefp;
	unsigned short   cth,cu,cpb,age_tmp;
	int			nitems, max_val;
	double			 time;
	char		     thfname[80], ufname[80], pbfname[80], agefname[80];
	// die definition von ifname mit char *ifname erzeugt mit gcc einen
	// segmentation fault (core dumped) Fehler waehrend des Programmlaufs 

printf("concentrations to ages - binary data stream version\n");
printf("author: P. Appel, CAU Kiel EPMA lab, v beta 0.2-mac, 25-05-05 \n");
	strcpy(thfname , "");
	strcpy(ufname , "");
	strcpy(pbfname , "");
	strcpy(agefname , "");

	printf("Enter file name Th: ");
	scanf( "%s", thfname);
	printf("Enter file name U: ");
	scanf( "%s", ufname);
	printf("Enter file name Pb: ");
	scanf( "%s", pbfname);
	printf("Shall calculate Th*-map? (y/n) ");
// scanf( "%s", thstar);

	printf("\nEnter age file name prefix: ");
	scanf( "%s", agefname);

	printf("\nNow calculating age map data. This may take some time. WAIT");

    thfp=fopen(thfname,"r");
    if (!thfp)
        return 1;
     ufp=fopen(ufname,"r");
    if (!ufp)
        return 1;
     pbfp=fopen(pbfname,"r");
    if (!pbfp)
        return 1;
        
    agefp=fopen(agefname,"w");
    if (!agefp)
        return 2;  
        nitems = 0; max_val = 1;
       
 while (!feof(thfp))
        {
        fread((char*)(&cth),sizeof(unsigned short),1,thfp);        
	fread((char*)(&cu),sizeof(unsigned short),1,ufp);        
        fread((char*)(&cpb),sizeof(unsigned short),1,pbfp);        

	time = ApaAge((double) (cth)/1000, (double) (cu)/1000, (double) (cpb)/1000);

		if (time < 0)
			time = 0;
		if (time > 4500)
			time = 4500;
  		nitems++; 
  		age_tmp = (unsigned short) time;
        if (age_tmp > max_val)
        	max_val = age_tmp;
        fwrite(&age_tmp,sizeof(unsigned short),1,agefp);
	}
	
fclose(agefp);
fclose(thfp);
fclose(ufp);
fclose(pbfp);
strcat(agefname, ".age");
printf("\nOutput is written to %s\n", agefname);

printf("Max Value %d\n", max_val);
printf("Done\n");

    return (0);
}

 
 
int main()
{
    int i;
    FILE *ifp, *ofp;
	unsigned short   cts_tmp;
	unsigned short     conc_tmp;
	int				 nitems, max_val;
	 float			 conc_ftmp, a_val, b_val, zaf_val, tdwell, pa;
	char		     *ifname, *ofname;

printf("Calculation of concentration maps from Jeol intensity maps\n");
printf("© P. Appel, CAU Kiel, v beta 0.2-mac, 25-May-2005 \n");
	strcpy(ifname , "");
	strcpy(ofname , "");

	printf("\nEnter input file name: ");
	scanf( "%s", ifname);


	printf("\nEnter a, b, ZAF, t [ms], pc [µA]: ");
	scanf( "%f %f %f %f %f", &a_val, &b_val, &zaf_val, &tdwell, &pa);

	strncat(ofname,ifname, strcspn(ifname, "."));
	strcat(ofname, ".con");
	printf("Output will be written to %s\n", ofname);

    ifp=fopen(ifname,"r+");
    if (!ifp)
        return 1;
        
    ofp=fopen(ofname,"w");
    if (!ofp)
        return 2;  
        nitems = 0; max_val = 1;
        
        while (!feof(ifp)) 
        {
        fread((char*)(&cts_tmp),sizeof(unsigned short),1,ifp);        
		conc_ftmp = ((cts_tmp/pa/tdwell - b_val) * zaf_val / a_val) * 1000; 
     	// conc_ftmp = 0.345 * 1000;
  		nitems++; 
  		conc_tmp = (unsigned short) conc_ftmp;
        if (conc_tmp > max_val)
        	max_val = conc_tmp;
        fwrite(&conc_tmp,sizeof(unsigned short),1,ofp);
     // printf("%f   %d  \n", ftmp, nitems); 
		}
		
fclose(ifp);
fclose(ofp);
printf("Max Value %d\n", max_val);
printf("Done\n");

    return 0;
}

*/
	   
		     
/*******************************************> Calculate Apparant Age <*/
double ApaAge(double Th, double U, double Pb)
{
double		lhs, diff, t, prev_t, delta_t;
float			steps, intervall, d_t;
diff = 0;
t = 1;
intervall = 4500;
steps = 10;
delta_t = intervall/steps;
lhs = Pb/224;
do  
	{
	do
		{
		diff = Th/264*(exp(0.000049475*t)-1)+U/270*((exp(0.00098485*t)+138*exp(0.000155125*t))/139-1) - lhs;
		if (diff < 0)
			{		
			prev_t = t;
			t = t + delta_t;
			}
		}
	while  ((diff < 0));
		{
		d_t=prev_t-t;
		intervall = t-prev_t; 
		t = prev_t;
		diff = 0;
		delta_t = intervall/steps;
		}
	}
while ( (d_t < -.2) );
return t;
}

