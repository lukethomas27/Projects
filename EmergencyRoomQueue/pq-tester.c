#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "list.h"
#include "emalloc.h"

#define MAX_LINE_LEN 5000

void inccounter(Patient *p, void *arg) {
    /* DO NOT CHANGE THIS FUNCTION. */
    int *ip = (int *)arg;
    (*ip)++;
}


void print_word(Patient *p, void *arg) {
    /* DO NOT CHANGE THIS FUNCTION. */
    char *fmt = (char *)arg;
    printf(fmt, p->name, p->birth_year, p->priority);
}


void dump(Patient *list) {
    /* DO NOT CHANGE THIS FUNCTION. */
    int len = 0;

    apply(list, inccounter, &len);    
    printf("Number of patients: %d\n", len);

    apply(list, print_word, "%s,%d,%d\n");
}

Patient *tokenize_line(char *line) {
    /* TODO: You have to implement this function to tokenize a line
        and either:
        1) return a valid Patient pointer if the line command is enqueue
        2) return NULL if the line command is dequeue
    */
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
    /* TODO: You have to implement this function to tokenize all lines
        from the stdin. You HAVE TO use the tokenize_line function
        as an auxiliary function to parse each line.
        If tokenize_line returns a valid Patient pointer, add the
        patient to the list with the correct priority.
        Otherwise, dequeue the first patient from the list.
        At the end of the function, return the list to the caller.       
    */
	char* buffer[100];
	while(fgets(buffer, sizeof(buffer), stdin)){
		Patient* temp = tokenize_line(buffer);
		list = add_with_priority(list, temp);
	}
	return list;
}

void deallocate_memory(Patient *list) {
    /* TODO: You have to implement this function to deallocate (free) 
        memory from the list before the program ends
    */
     Patient* temp;
     while(list!=NULL){
	temp = list;
	list = list->next;
	free(temp);
     }
}


int main(int argc, char *argv[]) {
    /* DO NOT CHANGE THE MAIN FUNCTION. YOU HAVE TO IMPLEMENT YOUR
        CODE TO FOLLOW THE SEQUENCE OF INSTRUCTIONS BELOW. */
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
