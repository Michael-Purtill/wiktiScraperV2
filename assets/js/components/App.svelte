<script>
    import * as ld from 'lodash';
    import { onMount } from 'svelte';
    
    
    let fileNames = [];
    onMount(async () => {
        let langList = [];
        fetch("/api/langlist").then((r) => {return r.json()}).then((d) => {langList = d.langs })
    })
        
    </script>
    
    <div>
        <h3>Please Select a Language</h3>
        
    </div>