include(ExternalProject)

set(LIBVPX_PATCHES_DIR ${third_party_loc}/patches/libvpx)
set(LIBVPX_PATCHES
    ${LIBVPX_PATCHES_DIR}/0001-armv7-use-hard-float.patch
    ${LIBVPX_PATCHES_DIR}/0002-Skip-diff-version-check-that-doesnt-work-with-busybo.patch
    ${LIBVPX_PATCHES_DIR}/0003-write_superframe_index-return-0-if-buffer-is-full.patch
)

set(LIBVPX_ARCH_FLAGS "")

if(CMAKE_SYSTEM_PROCESSOR MATCHES i486)
    set(LIBVPX_ARCH_FLAGS "--as=yasm") 
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES aarch64)
    set(LIBVPX_ARCH_FLAGS "--disable-neon_i8mm")
endif()

ExternalProject_Add(libvpx_external
    GIT_REPOSITORY "https://github.com/webmproject/libvpx"
    GIT_TAG v1.16.0
    GIT_SHALLOW 1

    PATCH_COMMAND git reset --hard HEAD && git apply ${LIBVPX_PATCHES}

    CONFIGURE_COMMAND <SOURCE_DIR>/configure
        --disable-unit-tests --disable-examples --disable-tools --disable-docs
        --prefix=<INSTALL_DIR>
        --enable-vp8 --enable-vp9 --enable-vp9-highbitdepth
        --enable-multithread --enable-postproc --enable-vp9-postproc
        --enable-experimental
        ${LIBVPX_ARCH_FLAGS}
        --enable-pic --size-limit=8192x8192

    BUILD_COMMAND make
    INSTALL_COMMAND make install
)

ExternalProject_Get_Property(libvpx_external INSTALL_DIR)

# create an empty folder so configuring won't fail
file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

add_library(tg_owt::libvpx STATIC IMPORTED GLOBAL)

set_target_properties(tg_owt::libvpx PROPERTIES
    IMPORTED_LOCATION ${INSTALL_DIR}/lib/libvpx.a
    INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include
)

add_dependencies(tg_owt::libvpx libvpx_external)
