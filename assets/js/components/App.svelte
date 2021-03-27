<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let langList = [];
    onMount(async () => {
        fetch("/api/langlist").then((r) => {return r.json()}).then((d) => {langList = _.filter(d.langs, (l) => l != "") })
    })
        
</script>
    
    <div>
        <h3>Please Select a Language</h3>
        <div>
            <select>
                {#each langList as lang}
                <option value={lang}>{lang}</option>
                {/each}
            </select>

        </div>
    </div>