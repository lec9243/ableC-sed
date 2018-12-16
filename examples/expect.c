#include <stdio.h>
#include <regex.h>
#include <string.h>
#include <stdlib.h>
char * delete(int address[], char in[]);
char * append(int address[], char in[], char app[]);
char * replace(int address[], char in[], char rep[], char tar[]);
int findaddress(char in[], char par[]);


int MAX_SIZE = 500;
int main(void)
{
  char * in = malloc(MAX_SIZE);
  char * out = malloc(MAX_SIZE);
  int add[2] = {-1, -1};
  in = "abc\ndef\nhello world\nhi world\nhi\n";
  add[0] = findaddress(in, "\\(he[a-z][a-z]o\\)");
  add[1] = add[0];
  printf("original: \n%s\n", in);
  in = delete(add, in);
  printf("delete string: \n%s\n", in);
  in = append(add, in, " test test");
  printf("append string: \n%s\n", in);
  int add1[2] = {1, 1};
  in = "aa\nb abc\nc\nd1\ne\n";
  printf("new string: \n%s\n", in);
  in = replace(add1, in, "\\([a-z]+\\)", " test test");
  printf("replace string: \n%s\n", in);

  return 0;
}

int findaddress(char in[], char par[])
{
  int count = 0;
  regex_t re;
  size_t nmatch = 1;
  regmatch_t pmatch[1];
  regcomp(&re, par, 0);
  int res = regexec(&re, in, nmatch, pmatch, 0);
  for (size_t i = 0; i < pmatch[0].rm_so; i++)
  {
     if (in[i] == '\n')
     {   count ++;  }
  }
  // printf("result: %d\n", res);
  // printf("pmatch[0] start: %d\n", pmatch[0].rm_so);
  // printf("pmatch[0] end: %d\n", pmatch[0].rm_eo);
  return count;
}

char * delete(int address[], char in[])
{
  int count = 0;
  int index = 0;
  char * temp = malloc(MAX_SIZE);
  for (int i = 0; i < strlen(in); i++)
  {
    if (count >= address[0] && count <= address[1])
    {
    }
    else
    {
      temp[index] = in[i];
      index ++;
    }
    if (in[i+1] == '\n')
    {  count ++; }
  }
 return temp;
}


char * append(int address[], char in[], char app[])
{
  int count = 0;
  int index = 0;
  char * temp = malloc(MAX_SIZE);
  for (int i = 0; i < strlen(in); i++)
  {
    temp[index] = in[i];
    index ++;
    if (in[i+1] == '\n')
    {
      count ++;
      if (count >= address[0] && count <= address[1])
      {
        for (int j = 0; j < strlen(app); j++)
        {
          temp[index] = app[j];
          index ++;
        }
      }
    }
  }
 return temp;
}

char * replace(int address[], char in[], char rep[], char tar[])
{
  int count = 0;
  int index1 = 0;
  int index2 = 0;
  int start = 0, end = 0;
  char * temp1 = malloc(MAX_SIZE/2);
  char * temp2 = malloc(MAX_SIZE/2);
  char * temp3 = malloc(MAX_SIZE/2);
  char * temp4 = malloc(MAX_SIZE/2);
  //temp1 = temp2 = temp3 = temp4 = "\0";
  for (int i = 0; i < strlen(in); i++)
  {
    if (in[i] == '\n')
    {
      count ++;
      if (count == address[0])
      { start = i; }
      else if (count == address[1]+1)
      { end = i; }
    }

    if (count < address[0])
    {
      temp1[i] = in[i];
    }
    else if (count >= address[0] && count <= address[1])
    {
      temp2[index1] = in[i];
      index1++;
    }
    else if (count > address[1])
    {
      temp4[index2] = in[i];
      index2++;
    }
  }
  regex_t re;
  size_t nmatch = 1;
  regmatch_t pmatch[1];
  regcomp(&re, rep, 0);
  int res = regexec(&re, temp2, nmatch, pmatch, REG_EXTENDED);
  int z = 0;
  while (z < strlen(temp2) - strlen(rep) + strlen(tar))
  {
    if (z <pmatch[0].rm_so)
    {
      temp3[z] = temp2[z];
    }
    else if (z = pmatch[0].rm_so)
    {
      for (int l = 0; l < strlen(tar); l ++)
      {
        temp3[z+l] = tar[l];
      }
      z = z+strlen(tar);
    }
    else
    {
      temp3[z] = temp3[z-strlen(tar)+strlen(rep)];
    }
    z++;
  }
  char * temp = malloc(MAX_SIZE);
  for (int m = 0;  m < strlen(temp1); m++)
  {
    temp[m] = temp1[m];
  }
  for (int m = 0;  m < strlen(temp3); m++)
  {
    temp[m+strlen(temp1)] = temp3[m];
  }

  for (int m = 0;  m < strlen(temp4); m++)
  {
    temp[m+strlen(temp1)+strlen(temp3)] = temp4[m];
  }
  //strcat(temp, temp3);
  // strcat(temp, temp2);
  // strcat(temp, temp4);

 return temp;
}
