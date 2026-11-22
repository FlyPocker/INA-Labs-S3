#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[])
{
  if(argc != 4){
    printf(2, "Uzycie: expr <a> <operator> <b>\n");
    exit();
  }

  int a = atoi(argv[1]);
  int b = atoi(argv[3]);
  
  char op = argv[2][0]; 
  
  int wynik = 0;

  if(op == '+'){
    wynik = a + b;
  } 
  else if(op == '-'){
    wynik = a - b;
  } 
  else if(op == '*'){
    wynik = a * b;
  } 
  else if(op == '/'){
    if(b == 0){
      printf(2, "Blad: Dzielenie przez zero!\n");
      exit();
    }
    wynik = a / b;
  }
  else if(op == '%'){
    if(b == 0){
      printf(2, "Blad: Dzielenie przez zero!\n");
      exit();
    }
    wynik = a % b;
  }
  else if(op == '^'){
    wynik = 1;
    for(int i = 0; i < b; i++){
      wynik = wynik * a;
    }
  } 
  else {
    printf(2, "Blad: Nieznany operator '%c'\n", op);
    exit();
  }

  printf(1, "%d\n", wynik);
  
  exit();
}