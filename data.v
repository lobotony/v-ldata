module ldata

import os

struct Data {
    pub mut:
    data byteptr
    size u64
}

fn (self Data) str() string {
    return 'Data{${self.data.hex()} ${self.size}}'
}

pub fn init_with_file(path string) Data { 
	mode := 'rb'
	mut fp := &C.FILE{}
	$if windows {
		fp = C._wfopen(path.to_wide(), mode.to_wide())
	} $else {
		cpath := path.str
		fp = C.fopen(cpath, mode.str) 
	}
	if isnil(fp) {
		panic('failed to open file $path')
	}
	C.fseek(fp, 0, C.SEEK_END)
	fsize := int(C.ftell(fp))
	C.rewind(fp)
	data := malloc(fsize)
	C.fread(data, fsize, 1, fp)
	C.fclose(fp)
    result := Data{data, u64(fsize)}
    println('$path [ $fsize bytes ]')
	return result
}

pub fn (self Data) deinit() {
	free(self.data)
}
