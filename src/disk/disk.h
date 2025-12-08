#ifndef DISK_H
#define DISK_H

#include "fs/file.h"


typedef unsigned int BROCESSOROS_DISK_TYPE;

// Represents a real physical hard disk
#define BROCESSOROS_DISK_TYPE_REAL 0

struct disk {
    BROCESSOROS_DISK_TYPE type;
    int sector_size;
    
    int id;
    void* fs_private;
    
    struct filesystem* filesystem;
};

void disk_search_and_init();

struct disk* disk_get(int index);

// int disk_read_sector(int lba, int total, void* buf);

int disk_read_block(struct disk* idisk, unsigned int lba, int total, void* buf);

#endif
