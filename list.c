/*
 * linkedlist.c
 *
 * Based on the implementation approach described in "The Practice 
 * of Programming" by Kernighan and Pike (Addison-Wesley, 1999).
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "emalloc.h"
#include "list.h"


Patient *new_patient(char *name, int birth_year, int priority) {
    assert( name != NULL);

    Patient *temp = (Patient *)emalloc(sizeof(Patient));

    temp->name       = strdup(name);
    temp->birth_year = birth_year;
    temp->priority   = priority;
    temp->next       = NULL;

    return temp;
}


Patient *add_front(Patient *list, Patient *new) {
    new->next = list;
    return new;
}


Patient *add_end(Patient *list, Patient *new) {
    Patient *curr;

    if (list == NULL) {
        new->next = NULL;
        return new;
    }

    for (curr = list; curr->next != NULL; curr = curr->next);
    curr->next = new;
    new->next = NULL;
    return list;
}


Patient *add_with_priority(Patient *list, Patient *new) {
    if (list == NULL) {
        list = new;
        return list;
    }
    if (new->priority < list->priority) {
        new->next = list;
        return new;
    } else {
        Patient *temp = list;
        while (temp->next != NULL) {
            if (new->priority < temp->next->priority) {
                new->next = temp->next;
                temp->next = new;
                return list;
            }
            temp = temp->next;
        }
        temp->next = new;
        return list;
    }
}
		

Patient *peek_front(Patient *list) {
    return list;
}


Patient *remove_front(Patient *list) {
    if (list == NULL) {
        return NULL;
    }

    return list->next;
}


void apply(Patient *list,
           void (*fn)(Patient *list, void *),
           void *arg)
{
    for ( ; list != NULL; list = list->next) {
        (*fn)(list, arg);
    }
}
