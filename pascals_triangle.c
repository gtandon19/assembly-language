#include <stdio.h>
/*This code was used to generate rows of the Pascal's Triangle
partners: ronitk2, ddamani2
The first loop is for calculating which number of the row it's calculating
while the inner loop calculates the number itself.*/
int main()
{
    unsigned long k, n, i; /*Initialising variables*/
    printf("Enter the row index: ");
    scanf("%lu", &n);
    printf("\n");
    k = 0;
    while (k <= n) /*Calculating the Kth number to print*/
    {
      unsigned long element;
      element = 1;
      i = 1;
      while (i <= k) /*Calculating the number to print*/
      {
        element = element*(n+1-i)/(i);
        i++;
      }
      printf("%lu ", element); /*Print command, with %lu for unsigned long*/
      k++;
    }
    return 0;
}
