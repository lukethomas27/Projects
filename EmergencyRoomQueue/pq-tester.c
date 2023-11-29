#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "list.h"
#include "emalloc.h"

#define MAX_LINE_LEN 5000

void inccounter(Patient *p, void *arg) {
    
    int *ip = (int *)arg;
    (*ip)++;
}


void print_word(Patient *p, void *arg) {
    
    char *fmt = (char *)arg;
    printf(fmt, p->name, p->birth_year, p->priority);
}


void dump(Patient *list) {
    
    int len = 0;

    apply(list, inccounter, &len);    
    printf("Number of patients: %d\n", len);

    apply(list, print_word, "%s,%d,%d\n");
}

Patient *tokenize_line(char *line) {

    char* token = strtok(line, ",");
    char d[10] = "dequeue";
    if(strcmp(token, d)==0){
	return NULL;
    }
    token = strtok(NULL, ",");
    char* name = token;
    token = strtok(NULL, ",");
    int birth_year = atoi(token);
    token = strtok(NULL, ",");
    int priority = atoi(token);
    return new_patient(name, birth_year, priority);
}

Patient *read_lines(Patient *list) {
    
	char* buffer[100];
	while(fgets(buffer, sizeof(buffer), stdin)){
		Patient* temp = tokenize_line(buffer);
		list = add_with_priority(list, temp);
	}
	return list;
}

void deallocate_memory(Patient *list) {
    
     Patient* temp;
     while(list!=NULL){
	temp = list;
	list = list->next;
	free(temp);
     }
}


int main(int argc, char *argv[]) {
    
    Patient *list = NULL;

    if (argc != 1) {
            printf("Usage: %s\n", argv[0]);
            printf("Should receive no parameters\n");
            printf("Read from the stdin instead\n");
            exit(1);
    }

    list = read_lines(list);
 
    dump(list);
    
    deallocate_memory(list);

    exit(0); 
}
