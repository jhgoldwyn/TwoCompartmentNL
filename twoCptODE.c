#include <stdio.h>
#include <math.h> 
#include <stdlib.h>
//#include <memory.h>

FILE *output, *NMfile;

// what data to save
int writeData; /* command line input */

// simulation run time
double tStop; /* command line input */

/* FIXED PARAMETERS */
/* reversal potentials*/
double ena=35.,ek=-90.,esyn=0.;
double hHalf=-57.;
double Q10 = 2.5 ;/* Q10 factor */
double temp = 40.; /* temperature [C] */
double spikeThreshold = -30.; 

/* general variables */
double tEnd,dt;
double phi;
double cap[2];
double gax;
double iax[2];
double v[2],m[2],h[2],n[2],d[2];
double elk[2];
double glk[2],gna[2],gkht[2],gklt[2];
double ilk[2],ina[2],ikht[2],iklt[2];
double alphad[2],betad[2],alphan[2],betan[2],alpham[2],betam[2],alphah[2],betah[2];
double dinf[2],minf[2],hinf[2],ninf[2];
double taud[2],taum[2],tauh[2],taun[2];
double isyn[2];
double hdenom;
float gsyn;
double vOld;
char* pythonPID;

int main(int argc, char *argv[])
{
    int i;
    int j=0; /* index for a ccessing gsyn. time step must match NM calculation */
    double t=0;
    double dv[2],dh[2],dm[2],dn[2],dd[2];
    char nmstr[20];

    pythonPID = argv[18];

    for (i=0;i<2;i++)
    { 
      cap[i] = atof(argv[i+4]);
      glk[i] = atof(argv[i+6]);
      gna[i] = atof(argv[i+8]);
      gkht[i] = atof(argv[i+10]);
      gklt[i] = atof(argv[i+12]);
      elk[i] = atof(argv[i+14]);
    }

    writeData = atoi(argv[1]);
    tEnd = atof(argv[2]);
    dt = atof(argv[3]);

    char filename_nm[500];
    /* open file for reading NM data */
    sprintf(filename_nm, "C_Intermediate_Output/NMfile-%s.txt", pythonPID);
    NMfile = fopen(filename_nm,"r");

    /* setup file for saving data */
    char filename_spike[500];
    char filename_volt[500];
    sprintf(filename_spike, "C_Intermediate_Output/Spikes-gNa=%.3f-%s.txt", gna[1], pythonPID);
    sprintf(filename_volt, "C_Intermediate_Output/Voltages-gNa=%.3f-%s.txt", gna[1], pythonPID);
    output=fopen(filename_spike, "w");
    if (writeData==1){
      output=fopen(filename_volt, "w"); /* to do: give name for voltage file */
    }


    /* Parameters from command line */ 

    

    
    gax = atof(argv[16]);
    hdenom = atof(argv[17]); 
    

    /* initial values */
    for (i=0;i<2;i++)
    { 
      v[i] = -62.;
      m[i] = 0.;
      h[i] = .8;
      n[i] = 0.;
      d[i] = 0.;
    }

    /* temperature adjustment */
    phi = pow(Q10, (temp-23.)/10.);

    while(t<(tEnd-dt/2.))
    {
    
        /* synaptic input */
        fgets(nmstr,20, NMfile);
	gsyn = atof(nmstr); //-(DC + AC*math.sin(2.*math.pi*t*f/1000.)) // (phase shift parameter)
        isyn[0] = gsyn*(v[0]-esyn);
        isyn[1] = 0.;

    	/* voltage-gated currents */
	for (i=0;i<2;i++)
	{ 
  	  /*KLT # Funabiki Table 2 # */
          alphad[i] = 0.20 * exp( (v[i]+60.)/21.8 );
          betad[i]  = 0.17 * exp(-(v[i]+60.)/14. );
          dinf[i]   = alphad[i]/ ( alphad[i] + betad[i]); 
          taud[i]   = 1. / (alphad[i] + betad[i]); 

  	  /* KHT # Funabiki Table 2 */
	  alphan[i] = 0.110 * exp( (v[i]+19.)/9.1 );
	  betan[i] = 0.103 * exp(-(v[i]+19.)/20. );
	  ninf[i]   = alphan[i] / ( alphan[i] +betan[i]); 
	  taun[i]   = 1. / (alphan[i] + betan[i]); 
    
   	  /* Na  # Funabiki Table 2 # */
	  alpham[i] = 3.6 * exp( (v[i]+34)/7.5 );
	  betam[i]  = 3.6 * exp( -(v[i]+34)/10.0 );
	  minf[i]   = alpham[i] / (alpham[i] + betam[i]); 
	  taum[i]   = 1. / (alpham[i] + betam[i]); 

	  alphah[i] = 0.6 * exp( -(v[i]+57)/18.0 );
	  betah[i]  = 0.6 * exp(  (v[i]+57)/13.5 );
	  /* hinf   = alphah / (alphah + betah) */
	  hinf[i] = 1./(1+exp(+(v[i]-hHalf)/hdenom));
	  tauh[i]   = 1. / (alphah[i] + betah[i]);


	  ilk[i] = glk[i]*(v[i]-elk[i]);
	  iklt[i] = gklt[i]*d[i]*(v[i]-ek);
	  ikht[i] = gkht[i]*n[i]*(v[i]-ek);
	  ina[i]  = gna[i]*m[i]*h[i]*(v[i]-ena);

	}
        iax[0] = gax*(v[0]-v[1]);
        iax[1] = gax*(v[1]-v[0]);
     
        /* ODEs */
	for (i=0;i<2;i++)
	{ 
          dv[i] = -(ilk[i] + ina[i] + ikht[i] + iklt[i] + iax[i] + isyn[i])/cap[i];
          dm[i] = phi * ( minf[i]-m[i] ) / taum[i];
          dh[i] = phi * ( hinf[i]-h[i] ) / tauh[i];
          dn[i] = phi * ( ninf[i]-n[i] ) / taun[i];
          dd[i] = phi * ( dinf[i]-d[i] ) / taud[i]; 
	}

        /* update variables */
        vOld = v[1];
        t += dt;
	for (i=0;i<2;i++)
	{ 
          v[i] = v[i] + dt*dv[i];
          m[i] = m[i] + dt*dm[i];
          h[i] = h[i] + dt*dh[i];
          n[i] = n[i] + dt*dn[i];
          d[i] = d[i] + dt*dd[i];
	}

        /* write data */
	if (writeData==0){
          if ( (vOld<=spikeThreshold) && (v[1]>spikeThreshold)){
             fprintf(output,"%.5f\n",t);
             }
          }
	else if (writeData==1){
	  fprintf(output,"%.5f %.5f %.5f\n",t,v[0],v[1]);
          }

        j +=1;


    }  /* end Euler loop */

    fclose(output);
    fclose(NMfile);

} /* end main */
